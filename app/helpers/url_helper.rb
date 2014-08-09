module UrlHelper
  
  # Wraps ActionView::Helpers::AssetUrlHelper#image_path and returns an absolute URL to a specific image, including
  # current hostname and protocol.
  #
  # === Parameters
  #
  # [path]  the path to the image we wish to get the URL for
  #
  def image_url( path )
    "#{root_url}#{image_path(path)}".gsub(/([0-9a-z])\/\//, '\1/')
  end
  
  # Convenience function that returns the URL path for the provided article.
  #
  # === Parameters
  #
  # [article]   the Article to generate the path to
  def article_path( article )
    _article_path(:slug => article.full_url)
  end
  
  # Convenience function that returns the URL path for the provided category.
  #
  # === Parameters
  #
  # [article]   the Category to generate the path to
  def category_path( category )
    _category_path(:slug => category.url_slug)
  end
  
  # Convenience function that returns the URL path for showing all comments on an article.
  #
  # === Parameters
  #
  # [article]     the Article we wish to comment on
  def article_comments_path( article, comment_id = nil )
    Rails.application.routes.url_helpers._article_comments_path( :slug => article.full_url )+( comment_id.nil? ? '' : "#comment-#{comment_id}" )
  end
  
  # Convenience function that returns the URL for adding a comment on an article
  #
  # === Parameters
  #
  # [article]     the Article we wish to comment on
  # [comment-id]  an optional comment ID we want to reply to
  def new_comment_path( article, comment_id = nil )
    _new_article_comment_path( :slug => article.full_url, :reply_to => comment_id )
  end
end