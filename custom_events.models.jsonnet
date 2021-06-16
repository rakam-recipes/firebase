local common = import 'common.libsonnet';
local predefined = import 'predefined.jsonnet';
local util = import 'util.libsonnet';

local all_event_props = common.get_event_properties;
local unique_events = std.uniq(std.sort(std.map(function(attr) attr.event_name, all_event_props)));

local user_props = common.get_user_properties();
local target = std.extVar('schema');
local installRevenue = std.extVar('installRevenue');

local common_measures_all = common.measures + common.all_events_revenue_measures;
local common_measures = if (!installRevenue) then util.filter_object(function(k, measure) !std.objectHas(measure, 'category') || measure.category != 'Revenue', common_measures_all) else common_measures_all;

std.map(function(event_type)
  local current_event_props = std.filter(function(p) p.event_name == event_type, all_event_props);
  local event_db_name = std.filter(function(attr) attr.event_name == event_type, all_event_props)[0].event_db;

  local defined = if std.objectHas(predefined, event_type) then predefined[event_type] else null;

  local dimensions_for_event = common.generate_user_dimensions(user_props)
                               +
                               common.generate_event_dimensions(current_event_props)
                               +
                               if defined != null && std.objectHas(defined, 'dimensions') then defined.dimensions else {};
  {
    name: 'firebase_event_' + event_type,
    label: (if defined != null then '[Firebase] ' else '') + event_type,
    measures: common_measures + if defined != null && std.objectHas(defined, 'measures') then defined.measures else {},
    mappings: common.mappings,
    category: 'Firebase Events',
    relations: common.relations + if defined != null && std.objectHas(defined, 'relations') then defined.relations else {},
    sql: |||
      SELECT *, (1.0 * `user_ltv`.`revenue`) - coalesce(lag(`user_ltv`.`revenue`) over (PARTITION BY user_pseudo_id ORDER BY event_timestamp), 0) as ltv_increase FROM `%(project)s`.`%(dataset)s`.`events_*`
      WHERE event_name = '%(event)s' {%% if partitioned %%} AND _TABLE_SUFFIX BETWEEN FORMAT_DATE("%%Y%%m%%d", DATE '{{date.start}}') and FORMAT_DATE("%%Y%%m%%d", DATE '{{date.end}}') {%% endif %%}
      %(intraday_query)s
    ||| % {
      project: target.database,
      dataset: target.schema,
      event: event_db_name,
      intraday_query: if std.extVar('intradayAnalytics') == true then
        |||
          UNION ALL
          SELECT *, null FROM `%(project)s`.`%(dataset)s`.`events_intraday_*`
          WHERE event_name = '%(event)s' {%% if partitioned %%}  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE("%%Y%%m%%d", DATE '{{date.start}}') and FORMAT_DATE("%%Y%%m%%d", DATE '{{date.end}}') {%% endif %%}
        ||| % {
          project: target.database,
          dataset: target.schema,
          event: event_db_name,
        } else '',
    },
    dimensions: common.dimensions + dimensions_for_event,
  }, unique_events)
