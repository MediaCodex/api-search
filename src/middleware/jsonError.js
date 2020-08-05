import jsonError from 'koa-json-error'
import { omit, compose, evolve, ifElse, split } from 'ramda'

const isProd = env => () => {
  return (env || process.env.NODE_ENV) === 'production'
}

/**
 * Format error as JSON, omit stacktrace in prod
 *
 * @param {Boolean} [isProd]
 */
export default (env = undefined) => jsonError({
  postFormat: (e, obj) => {
    const remove = omit(['stack'])
    const toObj = compose((arr) => ({ ...arr }), split('\n    '))
    const format = evolve({ stack: toObj })
    return ifElse(isProd(env), remove, format)(obj)
  }
})
