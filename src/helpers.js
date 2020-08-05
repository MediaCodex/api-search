import serverless from 'serverless-http'
import { customAlphabet } from 'nanoid'
import nolookalikes from 'nanoid-dictionary/nolookalikes'

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

/**
 * Generate a short ID for use as a primary key
 *
 * @returns {string}
 */
export const nanoid = customAlphabet(nolookalikes, 10)
