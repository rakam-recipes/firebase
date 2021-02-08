{
  name: 'Overall (Revenue)',
  category: 'Firebase',
  filterSchema: [
    Date: {
      type: 'mappingDimension',
      value: {
        name: 'eventTimestamp',
      },
      defaultValue: 'P14D',
      isRequired: true,
    },
    Country: {
      type: 'dimension',
      value: {
        model: 'firebase_event_in_app_purchase',
        dimension: 'country',
      },
      isRequired: false,
    },
    Continent: {
      type: 'dimension',
      value: {
        model: 'firebase_event_in_app_purchase',
        dimension: 'continent',
      },
      isRequired: false,
    },
    "Install Source": {
      type: 'dimension',
      value: {
        model: 'firebase_event_in_app_purchase',
        dimension: 'install_source',
      },
      isRequired: false,
    },
    Version: {
      name: 'Version',
      type: 'dimension',
      value: {
        model: 'firebase_event_in_app_purchase',
        dimension: 'version',
      },
      isRequired: false,
    },
    Platform: {
      name: 'Platform',
      type: 'dimension',
      value: {
        model: 'firebase_event_in_app_purchase',
        dimension: 'platform',
      },
      isRequired: false,
    },
  ],
  reports: [
    {
      name: 'Revenue',
      x: 0,
      y: 0,
      h: 2,
      w: 6,
      component: 'r-table',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        dimensions: [
          {
            name: 'event_timestamp',
            timeframe: 'day'
          },
        ],
        measures: [
          'revenue_from_new_users',
          'revenue_from_retained_users',
          'revenue_from_whales',
          'revenue_whales_ratio',
          'revenue',
        ]
      },
    },
    {
      name: 'Revenue Conversion',
      x: 0,
      y: 2,
      h: 2,
      w: 6,
      component: 'r-table',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        dimensions: [
          {
            name: 'event_timestamp',
            timeframe: 'day'
          },
        ],
        measures: [
          'average_transaction_per_paying_user',
          'transaction_count_per_paying_user',
        ]
      },
    },
  ],
}
