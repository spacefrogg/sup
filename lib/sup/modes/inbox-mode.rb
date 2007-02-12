require 'thread'

module Redwood

class InboxMode < ThreadIndexMode
  register_keymap do |k|
    ## overwrite toggle_archived with archive
    k.add :archive, "Archive thread (remove from inbox)", 'a'
  end

  def initialize
    super [:inbox], [:inbox]
  end

  def killable?; false; end

  def archive
    cursor_thread.remove_label :inbox
    hide_thread cursor_thread
    regen_text
  end

  def multi_archive threads
    threads.each { |t| remove_label_and_hide_thread t, :inbox }
    regen_text
  end

  def handle_archived_update sender, t
    if contains_thread? t
      hide_thread t
      regen_text
    end
  end

# not quite working, and not sure if i like it anyways
#   def handle_unarchived_update sender, t
#     Redwood::log "unarchived #{t.subj}"
#     show_thread t
#   end

  def status
    super + "    #{Index.size} messages in index"
  end

  def is_relevant? m; m.has_label? :inbox; end

  def load_threads opts={}
    n = opts[:num] || ThreadIndexMode::LOAD_MORE_THREAD_NUM
    load_n_threads_background n, :label => :inbox,
                                 :when_done => (lambda do |num|
      opts[:when_done].call if opts[:when_done]
      BufferManager.flash "Added #{num} threads."
    end)
  end
end

end
