local common = import 'common.libsonnet';
local installRevenue = std.extVar('installRevenue');
local target = std.extVar('schema');
local predefined = import 'predefined.jsonnet';

local user_props = common.get_user_properties();

local all_event_props = common.get_event_properties();
local current_event_props = std.filter(function(p) p.event_name == 'in_app_purchase', all_event_props);


if installRevenue then [
  {
    label: 'In-app Purchase Distribution',
    name: 'firebase_event_in_app_purchase_distribution',
    sql: |||
      SELECT *,
      ROW_NUMBER() OVER(PARTITION BY events.user_id ORDER BY events.event_timestamp ASC) as purchase_number,
      COUNT() over (partition by events.user_id) as user_total_transactions
      %(user_jinja)s
      %(event_jinja)s
      %(event_jinja)s
      FROM (
        SELECT * FROM `%(project)s`.`%(dataset)s`.`events_*`
        WHERE event_name = '%(event)s' {%% if partitioned %%} AND _TABLE_SUFFIX BETWEEN FORMAT_DATE("%%Y%%m%%d", DATE '{{date.start}}') and FORMAT_DATE("%%Y%%m%%d", DATE '{{date.end}}') {%% endif %%}
      ) events
    ||| % {
      user_jinja: std.join('\n', common.generate_jinja_for_user_properties(user_props)),
      event_jinja: std.join('\n', common.generate_jinja_for_event_properties(current_event_props)),
      project: target.database,
      dataset: target.schema,
      event: 'in_app_purchase',
    },
    measures: {

    } + common.measures + predefined.in_app_purchase.measures,
    dimensions: {
      purchase_number: {
        type: 'integer',
        column: 'purchase_number',
      },
      user_total_transactions: {
        type: 'integer',
        column: 'user_total_transactions',
      },
    } + common.dimensions + common.generate_user_dimensions(user_props) + common.generate_event_dimensions(current_event_props),
  },
] else []
