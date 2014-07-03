module Viewpoint::EWS::Types
  class Task
    include Viewpoint::EWS
    include Viewpoint::EWS::Types
    include Viewpoint::EWS::Types::Item

    VALID_STATUSES = %w{NotStarted InProgress Completed WaitingOnOthers Deferred}

    TASK_KEY_PATHS = {
      complete?:         [:is_complete, :text],
      recurring?:        [:is_recurring, :text],
      start_date:        [:start_date, :text],
      due_date:          [:end_date, :text],
      reminder_due_by:   [:reminder_due_by, :text],
      reminder?:         [:reminder_is_set, :text],
      percent_complete:  [:percent_complete, :text],
      status:            [:status, :text],
   }

    TASK_KEY_TYPES = {
      recurring?:       ->(str){str.downcase == 'true'},
      complete?:        ->(str){str.downcase == 'true'},
      reminder?:        ->(str){str.downcase == 'true'},
      percent_complete: ->(str){str.to_i},
    }
    TASK_KEY_ALIAS = {}

    def set_status(status)
      raise Errors::InvalidInputError, "Not a valid status (#{status})." unless valid_status?(status)
      opts = {
        :conflict_resolution => "AutoResolve",
        :item_changes => [
          :item_id => {:id => id, :change_key => change_key},
          :updates => [
            {:set_item_field => {
              :field_uRI     => {:field_uRI => 'task:Status'},
              :task => {:sub_elements => [{:status => {:text => status}}]}
            }}
          ]
        ]
      }
      resp = ews.update_item(opts)
      resp.response_messages[0].success?
    end


    private


    def valid_status?(status)
      VALID_STATUSES.include?(status)
    end

    def key_paths
      super.merge(TASK_KEY_PATHS)
    end

    def key_types
      super.merge(TASK_KEY_TYPES)
    end

    def key_alias
      super.merge(TASK_KEY_ALIAS)
    end

  end
end
