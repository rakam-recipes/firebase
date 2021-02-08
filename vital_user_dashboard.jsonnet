local installRevenue = std.extVar('installRevenue');

{
  name: 'Overall (User)',
  category: 'Firebase',
  filters : {
    Date : {
      mappingDimension : "eventTimestamp",
      operation : "between",
      default : "P1Y",
      required : true
    },
    Country : {
      model : "firebase_events",
      dimension : "country",
      required : false
    },
    Continent : {
      model : "firebase_events",
      dimension : "continent",
      required : false
    },
    Install Source : {
      model : "firebase_events",
      dimension : "install_source",
      required : false
    },
    Version : {
      model : "firebase_events",
      dimension : "version",
      required : false
    },
    Platform : {
      model : "firebase_events",
      dimension : "platform",
      required : false
    }
  },
  reports: [
    {
      name: 'Users',
      x: 0,
      y: 0,
      height: 2,
      width: 6,
      component: 'r-table',
      type: 'segmentation',
      options: {
        model: 'firebase_events',
        measures: ['active_users', 'all_users', 'new_users', 'paying_users', 'whales_playing'],
        dimensions: [{
          name: 'event_timestamp',
          timeframe: 'day',
        }],
        reportOptions: {
          chartOptions: {
            type: null,
          },
        },
        limit: 1000,
      },
    },
    if installRevenue then {
      name: 'ARPU',
      x: 0,
      y: 2,
      height: 2,
      width: 3,
      component: 'r-table',
      type: 'segmentation',
      options: {
        model: 'firebase_events',
        measures: ['average_revenue_per_new_user', 'average_revenue_per_user', 'average_revenue_per_retained_user'],
        dimensions: [{
          name: 'event_timestamp',
          timeframe: 'day',
        }],
        reportOptions: {
          chartOptions: {
            type: null,
          },
        },
        limit: 1000,
      },
    },
    if installRevenue then {
      name: 'User Conversion',
      x: 3,
      y: 2,
      height: 2,
      width: 3,
      component: 'r-table',
      type: 'segmentation',
      options: {
        model: 'firebase_events',
        measures: ['percent_new_users_paying', 'percent_retained_users_paying'],
        dimensions: [{
          name: 'event_timestamp',
          timeframe: 'day',
        }],
        reportOptions: {
          chartOptions: {
            type: null,
          },
        },
        limit: 1000,
      },
    },
  ],
}
