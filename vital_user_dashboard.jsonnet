local installRevenue = std.extVar('installRevenue');

{
  name: 'Overall (User)',
  category: 'Firebase',
  filterSchema: {
    Date: {
      mappingDimension: 'eventTimestamp',
      defaultValue: 'P14D',
      isRequired: true,
    },
    Country: {
      dimension: 'firebase_events.country',
      isRequired: false,
    },
    Continent: {
      dimension: 'firebase_events.continent',
      isRequired: false,
    },
    'Install Source': {
      dimension: 'firebase_events.install_source',
      isRequired: false,
    },
    Version: {
      dimension: 'firebase_events.version',
      isRequired: false,
    },
    Platform: {
      dimension: 'firebase_events.platform',
      isRequired: false,
    },
  },
  reports: [
    {
      name: 'Users',
      x: 0,
      y: 0,
      h: 2,
      w: 6,
      component: 'r-table',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_events',
        dimensions: [
          {
            name: 'event_timestamp',
            timeframe: 'day',
          },
        ],
        measures: [
          'active_users',
          'all_users',
          'new_users',
          'number_of_events',
        ],
        reportOptions: {
          chartOptions: {
            type: null,
            columnOptions: [],
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },
        limit: 1000,
      },
    },
    if installRevenue then {
      name: 'ARPU',
      x: 0,
      y: 2,
      h: 2,
      w: 3,
      component: 'r-table',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_events',
        dimensions: [
          {
            name: 'event_timestamp',
            timeframe: 'day',
          },
        ],
        measures: [
          'average_revenue_per_new_user',
          'average_revenue_per_user',
          'average_revenue_per_retained_user',
        ],
        reportOptions: {
          chartOptions: {
            type: null,
            columnOptions: [],
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },

        limit: 1000,
        filters: null,
        orders: null,
      },
    },
    if installRevenue then {
      name: 'User Conversion',
      x: 3,
      y: 2,
      h: 2,
      w: 3,
      component: 'r-table',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_events',
        dimensions: [
          {
            name: 'event_timestamp',
            timeframe: 'day',
          },
        ],
        measures: [
          'paying_users',
          'percent_new_users_paying',
          'percent_retained_users_paying',
        ],
        reportOptions: {
          chartOptions: {
            type: null,
            columnOptions: [],
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },
        limit: 1000,
        filters: null,
        orders: null,
      },
    },
  ],
}
