# frozen_string_literal: true

# Reusable page-based pagination: slice collections and build pagination metadata.
# Include in any class that needs pagination (repositories, services, etc.).
#
# Example:
#   include Pagination
#   items = slice_for_page(all_items, page, limit)
#   meta = build_pagination_meta(page, limit, total)
module Pagination
  DEFAULT_LIMIT = 31
  MAX_LIMIT = 90

  # Normalize limit: ensure integer, apply default and cap.
  def normalize_limit(limit, default: DEFAULT_LIMIT, max: MAX_LIMIT)
    n = limit.to_i
    n = default if n < 1
    [n, max].min
  end

  # Normalize page: 1-based, minimum 1.
  def normalize_page(page)
    n = page.to_i
    n < 1 ? 1 : n
  end

  # Slice an array for the given page (1-based). Returns the slice or [].
  # For ActiveRecord::Relation use: relation.offset((page - 1) * limit).limit(limit)
  def slice_for_page(collection, page, limit)
    offset = (page - 1) * limit
    collection[offset, limit] || []
  end

  # Build the pagination hash for API responses: { page:, total_pages:, total:, limit:, has_next:, has_previous: }.
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
