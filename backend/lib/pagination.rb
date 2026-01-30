# frozen_string_literal: true

# Page-based pagination: slice collections and build pagination metadata for API responses.
module Pagination
  DEFAULT_LIMIT = 31
  MAX_LIMIT = 90

  def normalize_limit(limit, default: DEFAULT_LIMIT, max: MAX_LIMIT)
    n = limit.to_i
    n = default if n < 1
    [n, max].min
  end

  def normalize_page(page)
    n = page.to_i
    n < 1 ? 1 : n
  end

  def slice_for_page(collection, page, limit)
    offset = (page - 1) * limit
    collection[offset, limit] || []
  end

  def build_pagination_meta(page, limit, total)
    total_pages = total.positive? ? (total.to_f / limit).ceil : 0
    {
      page: page,
      total_pages: total_pages,
      total: total,
      limit: limit,
      has_next: page < total_pages,
      has_previous: page > 1
    }
  end
end
