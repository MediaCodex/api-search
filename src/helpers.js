import serverless from 'serverless-http'

/**
 * @param {import('koa').Koa} app Koa application
 * @param {import('koa').Koa}
 */
export const wrapper = (app, middlewares = []) => {
  // apply middleware
  for (const middleware of middlewares) {
    app.use(middleware)
  }

  // wrap koa for lambda
  return async (event, context) => {
    return serverless(app)(event, context)
  }
}
