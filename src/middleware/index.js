import jsonError from './jsonError'

// default middlewares
export default [jsonError()]

// re-export middelwares that don't require modification
export { default as validateBody } from './validateBody'
export { default as auth } from './auth'
