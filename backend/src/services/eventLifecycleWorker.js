// Dependency injection keeps lifecycle checks testable without a live database.
function createLifecycleService({ query, deleteChannel, canDelete }) {
  let running;
  async function sweep() {
    await query(`UPDATE events SET status = 'completed'
      WHERE status = 'published' AND ends_at IS NOT NULL AND ends_at <= NOW()`);
    const result = await query(`SELECT chat.event_id, chat.stream_channel_id
      FROM event_chat_channels chat JOIN events e ON e.id = chat.event_id
      WHERE e.status IN ('completed', 'cancelled')
         OR (e.ends_at IS NOT NULL AND e.ends_at <= NOW())`);
    for (const chat of result.rows) {
      // Keep the row as a retry record if Stream is unavailable or deletion fails.
      if (!canDelete()) continue;
      try {
        await deleteChannel(chat.stream_channel_id);
        await query('DELETE FROM event_chat_channels WHERE event_id = $1 AND stream_channel_id = $2',
          [chat.event_id, chat.stream_channel_id]);
      } catch (_) {
        console.error('Event chat cleanup failed; will retry', chat.event_id);
      }
    }
  }
  return {
    cleanup() {
      if (!running) running = sweep().finally(() => { running = null; });
      return running;
    }
  };
}
module.exports = { createLifecycleService };
