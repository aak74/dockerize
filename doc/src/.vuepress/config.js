module.exports = {
  base: '/ddoc/',
  title: 'Документация по проекту Портал Хлебпром',
  serviceWorker: true,
  themeConfig: {
    sidebar: [
      {
        title: 'Общая информация',
        children: [
          '/',
          '/development/',
          '/development/code-style.html',
          '/doc/',
        ]
      },
    ],
    sidebarDepth: 3
  },
};
