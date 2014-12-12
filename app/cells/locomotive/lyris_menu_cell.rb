module Locomotive
  class LyrisMenuCell < SubMenuCell

    protected

    def build_list
      add :lists, url: lyris_lists_path
      if params[:list_id] || (params[:action]=="show" && params[:controller]=="locomotive/lyris/lists")
        list_id = params[:list_id] ? params[:list_id] : params[:id]
        add :messages, url: lyris_list_messages_path(list_id)
      end
    end

  end
end
