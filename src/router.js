import Koa from 'koa'
import Router from '@koa/router'
import { handler as createHandler, middleware as createMiddleware } from './controllers/http/create'
import { handler as updateHandler, middleware as updateMiddleware } from './controllers/http/update'
import { handler as indexHandler, middleware as indexMiddleware } from './controllers/http/index'
import { handler as showHandler, middleware as showMiddleware } from './controllers/http/show'
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
router.get('/', indexHandler, ...indexMiddleware)
router.post('/', createHandler, ...createMiddleware)
router.get('/:slug', showHandler, ...showMiddleware)
router.put('/:slug', updateHandler, ...updateMiddleware)

// bind routes to koa
if (process.env.PATH_PREFIX) {
  router.prefix(process.env.PATH_PREFIX)
}
app.use(router.routes()).use(router.allowedMethods())
app.listen(3000)
console.log('listening on http://0.0.0.0:3000')
