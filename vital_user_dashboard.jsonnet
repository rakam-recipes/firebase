{
  name: 'VITAL (User)',
  category: 'Firebase',
  filterSchema: [
    {
      name: 'Date',
      type: 'mappingDimension',
      value: {
        name: 'eventTimestamp',
      },
      defaultValue: 'P14D',
      isRequired: true,
    },
    {
      name: 'Country',
      type: 'dimension',
      value: {
        model: 'firebase_events',
        dimension: 'country',
      },
      isRequired: false,
    },
    {
      name: 'Continent',
      type: 'dimension',
      value: {
        model: 'firebase_events',
        dimension: 'continent',
      },
      isRequired: false,
    },
    {
      name: 'Install Source',
      type: 'dimension',
      value: {
        model: 'firebase_events',
        dimension: 'install_source',
      },
      isRequired: false,
    },
    {
      name: 'Version',
      type: 'dimension',
      value: {
        model: 'firebase_events',
        dimension: 'version',
      },
      isRequired: false,
    },
    {
      name: 'Platform',
      type: 'dimension',
      value: {
        model: 'firebase_events',
        dimension: 'platform',
      },
      isRequired: false,
    },
  ],
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
          'paying_users',
          'whales_playing',
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
    {
      name: 'ARPU',
      x: 0,
      y: 2,
      h: 2,
      w: 3,
      component: 'r-table',
      type: 'segmentation',
      reportOptions: {
        modelName: 'firebase_events',
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
    {
      name: 'User Conversion',
      x: 3,
      y: 2,
      h: 2,
      w: 3,
      component: 'r-table',
      type: 1,
      reportOptions: {
        modelName: 'firebase_events',
        dimensions: [
          {
            name: 'event_timestamp',
            modelName: 'firebase_events',
            relationName: null,
            postOperation: {
              type: 'timestamp',
              value: 'day',
            },
            pivot: false,
          },
        ],
        measures: [
          {
            name: 'percent_new_users_paying',
            modelName: 'firebase_events',
            relationName: null,
          },
          {
            name: 'percent_retained_users_paying',
            modelName: 'firebase_events',
            relationName: null,
          },
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
