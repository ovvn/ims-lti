NonceStore = require './nonce-store'

# Five minutes
EXPIRE_IN_SEC = 5 * 60

class MemoryNonceStore extends NonceStore

  constructor: () ->
    @used = Object.create(null)

  isNew: (nonce, timestamp, next=()->)->

    if typeof nonce is 'undefined' or nonce is null or typeof nonce is 'function' or typeof timestamp is 'function' or typeof timestamp is 'undefined'
      return next new Error('Invalid parameters'), false

    @_clearNonces()

    firstTimeSeen = @used[nonce] is undefined

    if not firstTimeSeen
      return next new Error('Nonce already seen'), false

    @setUsed nonce, timestamp, (err) ->
      console.log {nonce, timestamp}
      if typeof timestamp isnt 'undefined' and timestamp isnt null
        timestamp = parseInt timestamp, 10
        currentTime = Math.round(+new Date() / 1000)
        console.log {currentTime, timestamp, EXPIRE_IN_SEC}
        timestampIsFresh = ((currentTime - timestamp) <= EXPIRE_IN_SEC)
        console.log {currentTime, timestampIsFresh}
        console.log 'diff ', currentTime - timestamp
        if (currentTime - timestamp) <= EXPIRE_IN_SEC
          next null, true
        else
          next new Error('Expired timestamp'), false
      else
        next new Error('Timestamp required'), false

  setUsed: (nonce, ts, next=()->)->
    @used[nonce] = ts + EXPIRE_IN_SEC
    next(null)

  _clearNonces: () ->
    now = Math.round(+new Date() / 1000)

    for nonce, expiry of @used
      console.log {expiry, now}
      delete @used[nonce] if expiry <= now

    return


exports = module.exports = MemoryNonceStore
