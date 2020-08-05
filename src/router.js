import Koa from 'koa'
import Router from '@koa/router'
import { handler as searchHandler, middleware as searchMiddleware } from './controllers/http/search'
import defaultMiddleware from './middleware'

/**
 * Initialise Koa
 */
const app = new Koa()
const router = new Router()
for (const middleware of defaultMiddleware) {
  app.use(middleware)
}

/**
 * Define routes
 */
router.post('/', searchHandler, ...searchMiddleware)

// bind routes to koa
if (process.env.PATH_PREFIX) {
  router.prefix(process.env.PATH_PREFIX)
}
app.use(router.routes()).use(router.allowedMethods())
app.listen(3000)
console.log('listening on http://0.0.0.0:3000')
