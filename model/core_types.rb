require "gorillib/model"
require File.expand_path("has_examples",     File.dirname(__FILE__))
require File.expand_path("fixup_on_receive", File.dirname(__FILE__))

module Icss

  class Thing
    include Gorillib::Model
    field :name, String
    field :description, String
    field :id,  String
  end
  
  class WebLink < Thing
    field :rel,                          String,           :doc =>"The relation described by this link. Common values include 'self' and 'alternate'"
    field :href,                         String,           :doc =>"A WWW Hyperlink. Do not use this property unless it is a proper URL."
  end                                    
                                         
  class Actor < Thing                    
    field :url,                          String,           :doc => "Url for this person or organization"
    field :location,                     Hash,             :doc => "Primary location of this person or organization"
  end

  class VideoObject < Thing
    field :height,                       Integer
  end    

  class Activity < Thing
    field :url,                          String,           doc: "URL for this creative work"
    field :title,                        String,           doc: "Name of entry type"
    field :summary,                      String,           doc: "A synopsis of the contents of this creative work"
    field :author,                       Actor,            doc: "Performs the activity"
    field :publisher,                    Icss::Actor,      doc: "The publisher of the creative work"
    field :provider,                     Icss::Actor,      doc: "Specifies the Person or Organization that distributed the creative work. For example, a tweet delivered over the Twitter API has Twitter as the provider (rather than as the publisher)."
    #
    field :published_at,                 Time,             doc: "Time of first broadcast/publication."
    field :published_at,                 Time,             doc: "Time of first broadcast/publication."
  end
  
  class Article < Activity
    field :text,                         String,           doc: "The textual content of this creative work"
  end

  # FIXME: ponder (and correct) the differences btwn this and Schema.org for similar
  
  class ForumArticle < Article
  end
  class NewsArticle < Article
  end
  class BlogArticle < Article
  end
    
  class Movie < Activity
    field :video,                         VideoObject,           doc: "The contents of this creative work"
  end
  
  class YoutubeMovie < Activity
  end
  
end

module Infomart
  module ReasonWhy
    extend Gorillib::Concern
    included do |base|
      base.field :matching_query, String, doc: "The query string that caused this activity to enter the stream"
      base.field :tagging_hints,  String, default: ->{ tagging_hints_default }, doc: "Gnip matching rules for Infomart"
    end
    
    def tagging_hints_default
      return unless matching_query
      # FIXME: figure out the tagging_hints and return them
    end
  end
  
  class ActivityStatistics
    include Gorillib::Model
    field :favorites_count, Integer
    field :views_count,     Integer
  end
  
  class YoutubeMovie < ::Icss::YoutubeMovie
    include ReasonWhy
    
    field  :statistics, ActivityStatistics
  end
end

