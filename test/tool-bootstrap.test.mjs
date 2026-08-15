import test from 'node:test'
import assert from 'node:assert/strict'
import { apply } from '../preset/tool-bootstrap.mjs'

const MINIMAL_PROMPT = 'You are a helpful software engineer assistant.'

function captureApply(config) {
  let handler
  const ctx = {
    on(event, fn) {
      if (event !== 'system-prompt/assemble') {
        throw new Error(`unexpected event: ${event}`)
      }
      handler = fn
    },
  }
  apply(ctx, config)
  if (!handler) {
    throw new Error('system-prompt/assemble handler was not registered')
  }
  return handler
}

test('bootstrap filters tools but keeps Minimal system prompt intact', async () => {
  const handler = captureApply({ shellTools: ['bash'], commonTools: ['read'] })
  const assembled = {
    systemPrompt: MINIMAL_PROMPT,
    tools: [
      { name: 'bash' },
      { name: 'read' },
      { name: 'write' },
    ],
  }
  const context = { agent: { session: { events: [] } } }
  const result = await handler(assembled, context, async () => assembled)

  assert.deepEqual(
    result.tools.map(tool => tool.name),
    ['bash', 'read'],
  )
  assert.equal(result.systemPrompt, MINIMAL_PROMPT)
})

test('Windows bootstrap keeps pwsh/read and Minimal system prompt intact', async () => {
  const handler = captureApply({ shellTools: ['bash', 'pwsh'], commonTools: ['read'] })
  const assembled = {
    systemPrompt: MINIMAL_PROMPT,
    tools: [
      { name: 'pwsh' },
      { name: 'read' },
      { name: 'write' },
    ],
  }
  const context = { agent: { session: { events: [] } } }
  const result = await handler(assembled, context, async () => assembled)

  assert.deepEqual(
    result.tools.map(tool => tool.name),
    ['pwsh', 'read'],
  )
  assert.equal(result.systemPrompt, MINIMAL_PROMPT)
})

test('after first durable tool call the full catalog is returned unchanged', async () => {
  const handler = captureApply({ shellTools: ['bash'], commonTools: ['read'] })
  const assembled = {
    systemPrompt: MINIMAL_PROMPT,
    tools: [
      { name: 'bash' },
      { name: 'read' },
      { name: 'write' },
    ],
  }
  const context = { agent: { session: { events: [{ type: 'tool/call' }] } } }
  const result = await handler(assembled, context, async () => assembled)

  assert.equal(result, assembled)
})
