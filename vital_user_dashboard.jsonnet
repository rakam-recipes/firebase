local installRevenue = std.extVar('installRevenue');

{
  name: 'Overall (User)',
  category: 'Firebase',
  filterSchema: {
    Date: {
      mappingDimension: 'eventTimestamp',
      default: 'P14D',
      required: true,
    },
    Country: {
      dimension: 'firebase_events.country',
      required: false,
    },
    Continent: {
      dimension: 'firebase_events.continent',
      required: false,
    },
    'Install Source': {
      dimension: 'firebase_events.install_source',
      required: false,
    },
    Version: {
      dimension: 'firebase_events.version',
      required: false,
    },
    Platform: {
      dimension: 'firebase_events.platform',
      required: false,
    },
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
