local predefined = import 'predefined.jsonnet';

{
  generate_user_dimensions(user_props)::
    std.foldl(function(a, b) a + b, std.map(function(attr) {
      ['user__' + attr.name]: {
        category: 'User Attribute',
        sql: "(SELECT value.%(value_type)s FROM UNNEST({{TABLE}}.user_properties) WHERE key = '%(prop_db)s')" % attr,
        type: attr.type,
      },
    }, user_props), {}),
  generate_event_dimensions(event_props)::
    std.foldl(function(a, b) a + b, std.map(function(attr) {
      ['event__' + attr.name]: {
        category: 'Event Attribute',
        sql: "(SELECT value.%(value_type)s FROM UNNEST({{TABLE}}.event_params) WHERE key = '%(prop_db)s')" % attr,
        type: attr.type,
      },
    }, event_props), {}),
  get_user_properties()::
    if std.extVar('user_properties') != null then std.extVar('user_properties') else
      [
        { name: 'last_deep_link_referrer', type: 'string', value_type: 'string_value', prop_db: 'last_deep_link_referrer', description: 'Last deep-link referrer value (2K-character limit)' },
      ],
  get_event_properties:
    if std.extVar('event_properties') != null then std.extVar('event_properties') else
      std.flattenArrays(std.map(function(event_type) std.map(function(prop)
                                                               { event_name: event_type, event_db: event_type, name: prop.name, prop_db: prop.prop_db, type: prop.type, value_type: prop.value_type },
                                                             if std.objectHas(predefined, event_type) then predefined[event_type].properties else []), std.objectFields(predefined)))
  ,
  mappings: {
    eventTimestamp: 'event_timestamp',
    userId: 'firebase_user_id',
    deviceId: 'advertising_id',
  },
  relations: {
    //   rel_sessions: {
    //     relationType: 'oneToOne',
    //     joinType: 'leftJoin',
    //     model: 'sessions',
    //     sql: |||
    //       {{dimension.user_pseudo_id}} = sessions.user_pseudo_id
    //       AND {{dimension.event_timestamp}} >= {{model.sessions.dimension.session_start.filter}}
    //       AND {{dimension.event_timestamp}} <= {{model.sessions.dimension.session_end.filter}}
    //     |||,
    //   },
  },
  measures: {
    all_users: {
      sql: '{{dimension.firebase_user_id}}',
      aggregation: 'countUnique',
    },
    number_of_events: {
      aggregation: 'count',
    },
    active_users: {
      aggregation: 'countUnique',
      sql: '{{dimension.firebase_user_id}}',
      filters: [
        { dimension: 'is_retained', operator: 'is', value: true, valueType: 'boolean' },
      ],
    },
    new_users: {
      aggregation: 'countUnique',
      sql: '{{dimension.firebase_user_id}}',
      filters: [
        { dimension: 'is_retained', operator: 'is', value: false, valueType: 'boolean' },
      ],
    }
  },
  dimensions: {
    event_timestamp: {
      sql: 'TIMESTAMP_MICROS({{TABLE}}.`event_timestamp`)',
      type: 'timestamp',
    },
    days_since_signup: {
      sql: 'TIMESTAMP_DIFF({{dimension.event_timestamp}}, {{dimension.user_first_touch}}, DAY)',
      type: 'integer',
    },
    weeks_since_signup: {
      sql: 'DATE_DIFF(CAST({{dimension.event_timestamp}} AS DATE), CAST({{dimension.user_first_touch}} AS DATE), WEEK)',
      type: 'integer',
    },
    firebase_user_id: {
      label: 'User Id',
      description: 'either user_id or user_pseudo_id',
      // sql: 'COALESCE({{dimension.user_id}}, {{dimension.user_pseudo_id}})',
      sql: '{{dimension.user_pseudo_id}}',
      type: 'string',
    },
    platform: {
      type: 'string',
      category: 'Event',
      column: 'platform',
    },
    is_retained: {
      type: 'boolean',
      category: 'Event',
      sql: 'TIMESTAMP_DIFF({{dimension.event_timestamp}}, {{dimension.user_first_touch}}, DAY) > 1',
    },
    // Revenue
    ltv_increase: {
      type: 'double',
      category: 'Revenue',
      column: 'ltv_increase',
    },
    event_value_in_usd: {
      type: 'double',
      category: 'Revenue',
      // it's only available in in_app_purchase
      hidden: true,
      column: 'event_value_in_usd',
    },
    is_whale: {
      type: 'boolean',
      category: 'Revenue',
      sql: "{{TABLE}}.`user_ltv`.`revenue` > 99 AND {{TABLE}}.`user_ltv`.`currency` = 'USD'",
    },
    is_paying: {
      type: 'boolean',
      category: 'Revenue',
      sql: 'coalesce({{TABLE}}.`user_ltv`.`revenue` > 0, false)',
    },
    ltv_revenue: {
      category: 'Revenue',
      sql: '{{TABLE}}.`user_ltv`.`revenue`',
      hidden: false,
      description: 'The increase of LTV of the user. It can be used to calculate LTC Cohorts but since subsequent events such as in_app_purchase -> screen_view may not include the ltv_revenue, it should not be grouped by event_name',
      type: 'double',
    },
    ltv_currency: {
      category: 'Revenue',
      type: 'string',
      sql: '{{TABLE}}.`user_ltv`.`currency`',
      hidden: true,
    },

    // Event related
    traffic_source_name: {
      type: 'string',
      category: 'Event',
      sql: '`traffic_source`.`name`',
    },
    traffic_source_medium: {
      type: 'string',
      category: 'Event',
      sql: '`traffic_source`.`medium`',
    },
    traffic_source_source: {
      type: 'string',
      label: 'Traffic Source Channel',
      category: 'Event',
      sql: '`traffic_source`.`source`',
    },
    user_first_touch: {
      description: 'The time at which the user first opened the app.',
      type: 'timestamp',
      category: 'Event',
      sql: 'TIMESTAMP_MICROS({{TABLE}}.`user_first_touch_timestamp`)',
    },
    user_id: {
      description: 'The user ID set via the setUserId API.',
      type: 'string',
      column: 'user_id',
      category: 'Event',
      hidden: true,
    },
    user_pseudo_id: {
      description: 'The pseudonymous id (e.g., app instance ID) which is unique for user install.',
      column: 'user_pseudo_id',
      hidden: true,
      category: 'Event',
      type: 'string',
    },

    // App Info
    id: {
      description: 'The package name or bundle ID of the app.',
      category: 'App Info',
      type: 'string',
      sql: '{{TABLE}}.`app_info`.`id`',
    },
    firebase_app_id: {
      description: 'The Firebase App ID associated with the app',
      category: 'App Info',
      type: 'string',
      sql: '{{TABLE}}.`app_info`.`firebase_app_id`',
    },
    version: {
      category: 'App Info',
      type: 'string',
      sql: '{{TABLE}}.`app_info`.`version`',
    },
    install_source: {
      description: 'The store that installed the app.',
      category: 'App Info',
      type: 'string',
      sql: '{{TABLE}}.`app_info`.`install_source`',
    },
    category: {
      description: 'The device category (mobile, tablet, desktop).',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`category`',
    },

    // Device
    browser_version: {
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`browser_version`',
    },
    browser: {
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`browser`',
    },
    advertising_id: {
      description: 'Advertising ID/IDFA.',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`advertising_id`',
    },
    is_limited_ad_tracking: {
      description: "he device's Limit Ad Tracking setting.",
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`is_limited_ad_tracking`',
    },
    operating_system: {
      description: 'The operating system of the device.',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`operating_system`',
    },
    mobile_os_hardware_model: {
      description: 'The device model information retrieved directly from the operating system.',
      type: 'string',
      category: 'Device',
      sql: '{{TABLE}}.`device`.`mobile_os_hardware_model`',
    },
    mobile_model_name: {
      description: 'The device model name.',
      type: 'string',
      category: 'Device',
      sql: '{{TABLE}}.`device`.`mobile_model_name`',
    },
    mobile_marketing_name: {
      description: 'The device marketing name.',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`mobile_marketing_name`',
    },
    mobile_brand_name: {
      description: 'The device brand name.',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`mobile_brand_name`',
    },
    language: {
      description: 'The OS language.',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`is_limited_ad_tracking`',
    },
    operating_system_version: {
      description: 'The OS version.',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`operating_system_version`',
    },
    time_zone_offset_seconds: {
      description: 'The offset from GMT in seconds.',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`time_zone_offset_seconds`',
    },
    vendor_id: {
      description: 'IDFV (present only if IDFA is not collected).',
      category: 'Device',
      type: 'string',
      sql: '{{TABLE}}.`device`.`vendor_id`',
    },

    // Geo
    city: {
      description: 'The city from which events were reported, based on IP address.',
      category: 'User Location',
      type: 'string',
      sql: '{{TABLE}}.`geo`.`city`',
    },
    continent: {
      description: 'The continent from which events were reported, based on IP address.',
      category: 'User Location',
      type: 'string',
      sql: '{{TABLE}}.`geo`.`continent`',
    },
    country: {
      description: 'The country from which events were reported, based on IP address.',
      category: 'User Location',
      type: 'string',
      sql: '{{TABLE}}.`geo`.`country`',
    },
    metro: {
      description: 'The metro from which events were reported, based on IP address.',
      category: 'User Location',
      type: 'string',
      sql: '{{TABLE}}.`geo`.`metro`',
    },
    region: {
      description: 'The region from which events were reported, based on IP address.',
      category: 'User Location',
      type: 'string',
      sql: '{{TABLE}}.`geo`.`region`',
    },
    sub_continent: {
      description: 'The subcontinent from which events were reported, based on IP address.',
      category: 'User Location',
      type: 'string',
      sql: '{{TABLE}}.`geo`.`sub_continent`',
    },
  },
  all_events_revenue_measures: {
    total_revenue: {
      aggregation: 'sum',
      label: 'Total Revenue',
      category: 'Revenue',
      sql: '{{dimension.ltv_increase}}',
      reportOptions: { formatNumbers: '$0,0[.]000000' },
    },
    ltv_revenue: {
      label: 'LTV',
      category: 'Revenue',
      sql: 'coalesce(IEEE_DIVIDE({{measure.total_revenue}}, {{measure.all_users}}), 0)',
      reportOptions: { formatNumbers: '$0,0[.]00000000' },
    },
    ltv_revenue_d0: {
      label: 'D0 LTV',
      category: 'Revenue',
      sql: '{{measure.ltv_revenue}}',
      description: 'Total revenue collected within 0 day from users whose first event was sent on D0 / Total number of users whose first event was sent on D0 and made an event within 0 day.',
      reportOptions: { formatNumbers: '$0,0[.]00000000' },
      filters: [
        { dimension: 'days_since_signup', operator: 'lessThan', value: 1, valueType: 'integer' },
      ],
    },
    ltv_revenue_d1: {
      label: 'D1 LTV',
      category: 'Revenue',
      sql: '{{measure.ltv_revenue}}',
      description: 'Total revenue collected within 1 day from users whose first event was sent on D0 / Total number of users whose first event was sent on D0 and made an event within 1 day.',
      reportOptions: { formatNumbers: '$0,0[.]00000000' },
      filters: [
        { dimension: 'days_since_signup', operator: 'lessThan', value: 2, valueType: 'integer' },
      ],
    },
    ltv_revenue_d3: {
      label: 'D3 LTV',
      category: 'Revenue',
      sql: '{{measure.ltv_revenue}}',
      description: 'Total revenue collected within 3 days from users whose first event was sent on D0 / Total number of users whose first event was sent on D0 and made an event within 3 days.',
      reportOptions: { formatNumbers: '$0,0[.]00000000' },
      filters: [
        { dimension: 'days_since_signup', operator: 'lessThan', value: 4, valueType: 'integer' },
      ],
    },
    ltv_revenue_d7: {
      label: 'D7 LTV',
      category: 'Revenue',
      sql: '{{measure.ltv_revenue}}',
      description: 'Total revenue collected within 7 days from users whose first event was sent on D0 / Total number of users whose first event was sent on D0 and made an event within 7 days.',
      reportOptions: { formatNumbers: '$0,0[.]00000000' },
      filters: [
        { dimension: 'days_since_signup', operator: 'lessThan', value: 8, valueType: 'integer' },
      ],
    },
    ltv_revenue_d30: {
      label: 'D30 LTV',
      category: 'Revenue',
      sql: '{{measure.ltv_revenue}}',
      description: 'Total revenue collected within 30 days from users whose first event was sent on D0 / Total number of users whose first event was sent on D0 and made an event within 30 days.',
      reportOptions: { formatNumbers: '$0,0[.]00000000' },
      filters: [
        { dimension: 'days_since_signup', operator: 'lessThan', value: 31, valueType: 'integer' },
      ],
    },
    whales_playing: {
      aggregation: 'countUnique',
      sql: '{{dimension.firebase_user_id}}',
      category: 'Revenue',
      filters: [
        { dimension: 'is_whale', operator: 'is', value: true, valueType: 'boolean' },
      ],
    },
    paying_users: {
      aggregation: 'countUnique',
      sql: '{{dimension.firebase_user_id}}',
      category: 'Revenue',
      filters: [{ dimension: 'is_paying', operator: 'is', value: true, valueType: 'boolean' }],
    },
    revenue: {
      aggregation: 'sum',
      label: 'IAP Revenue',
      category: 'Revenue',
      column: 'event_value_in_usd',
      reportOptions: { formatNumbers: '$0,0' },
    },
    average_revenue_per_user: {
      category: 'Revenue',
      label: 'IAP ARPU [All]',
      sql: '1.0 * ({{measure.revenue}}/{{measure.all_users}})',
      type: 'double',
      reportOptions: { formatNumbers: '$0,0.00' },
    },
    average_revenue_per_new_user: {
      aggregation: 'average',
      label: 'IAP ARPU [New users]',
      column: 'event_value_in_usd',
      category: 'Revenue',
      type: 'double',
      filters: [
        { dimension: 'is_retained', operator: 'is', value: false, valueType: 'boolean' },
      ],
      reportOptions: { formatNumbers: '$0,0.00' },
    },
    average_revenue_per_retained_user: {
      aggregation: 'average',
      label: 'IAP ARPU [Retained users]',
      column: 'event_value_in_usd',
      category: 'Revenue',
      type: 'double',
      filters: [
        { dimension: 'is_retained', operator: 'is', value: true, valueType: 'boolean' },
      ],
      reportOptions: { formatNumbers: '$0,0.00' },
    },
    paying_and_retained_users: {
      sql: '{{dimension.firebase_user_id}}',
      aggregation: 'countUnique',
      category: 'Revenue',
      filters: [
        { dimension: 'is_retained', operator: 'is', value: true, valueType: 'boolean' },
        { dimension: 'is_paying', operator: 'is', value: true, valueType: 'boolean' },
      ],
      type: 'double',
      hidden: true,
    },
    paying_and_new_users: {
      sql: '{{dimension.firebase_user_id}}',
      category: 'Revenue',
      aggregation: 'countUnique',
      filters: [
        { dimension: 'is_retained', operator: 'is', value: false, valueType: 'boolean' },
        { dimension: 'is_paying', operator: 'is', value: true, valueType: 'boolean' },
      ],
      type: 'double',
      hidden: true,
    },
    percent_retained_users_paying: {
      sql: '{{measure.paying_and_retained_users}}/{{measure.active_users}}',
      category: 'Revenue',
      reportOptions: { formatNumbers: '0.0%' },
    },
    percent_new_users_paying: {
      sql: '{{measure.paying_and_new_users}}/{{measure.new_users}}',
      category: 'Revenue',
      reportOptions: { formatNumbers: '0.0%' },
    },
  },
}
