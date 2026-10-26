<%@page import="mvc_olx.dto.Product"%>
<%@page import="java.util.List"%>
<%@page import="mvc_olx.helper.CurrencyFormatter"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<%!
    private String cleanName(String name) {
        if (name == null || name.isEmpty()) return "Unnamed Product";
        return name.replaceAll("\\s*\\(\\d+\\)\\s*$", "").trim();
    }
    private String fmtDate(java.sql.Date d) {
        if (d == null) return "";
        return new SimpleDateFormat("d MMM yyyy").format(d);
    }
%>
<html data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Products – OLX India</title>
    <meta name="description" content="Search and filter products on OLX India. Find mobiles, cars, bikes, electronics, furniture and more near you.">
    <%@ include file="fragments/head-scripts.jspf" %>
</head>
<body>
<%
    List<Product> products  = (List<Product>) request.getAttribute("products");
    String[] catList        = (String[]) request.getAttribute("categories");
    String[] condList       = (String[]) request.getAttribute("conditions");
    Long totalCount         = (Long) request.getAttribute("totalCount");
    Integer currentPage     = (Integer) request.getAttribute("currentPage");
    Integer totalPages      = (Integer) request.getAttribute("totalPages");

    String fQuery    = request.getAttribute("filterQuery")    != null ? (String) request.getAttribute("filterQuery")    : "";
    String fCategory = request.getAttribute("filterCategory") != null ? (String) request.getAttribute("filterCategory") : "";
    String fMinPrice = request.getAttribute("filterMinPrice") != null ? (String) request.getAttribute("filterMinPrice") : "";
    String fMaxPrice = request.getAttribute("filterMaxPrice") != null ? (String) request.getAttribute("filterMaxPrice") : "";
    String fCondition= request.getAttribute("filterCondition")!= null ? (String) request.getAttribute("filterCondition"): "";
    String fLocation = request.getAttribute("filterLocation") != null ? (String) request.getAttribute("filterLocation") : "";
    String fSortBy   = request.getAttribute("filterSortBy")   != null ? (String) request.getAttribute("filterSortBy")   : "newest";

    if (currentPage == null) currentPage = 1;
    if (totalPages  == null) totalPages  = 1;
    if (totalCount  == null) totalCount  = 0L;

    boolean anyFilter = !fQuery.isEmpty() || !fCategory.isEmpty() || !fMinPrice.isEmpty() || !fMaxPrice.isEmpty() || !fCondition.isEmpty() || !fLocation.isEmpty();
    int activeFilterCount = (fQuery.isEmpty() ? 0 : 1) + (fCategory.isEmpty() ? 0 : 1) +
                            (fMinPrice.isEmpty() && fMaxPrice.isEmpty() ? 0 : 1) +
                            (fCondition.isEmpty() ? 0 : 1) + (fLocation.isEmpty() ? 0 : 1);

    // Base query string for pagination links
    StringBuilder baseQS = new StringBuilder();
    if (!fQuery.isEmpty())    baseQS.append("&q=").append(java.net.URLEncoder.encode(fQuery,"UTF-8"));
    if (!fCategory.isEmpty()) baseQS.append("&category=").append(java.net.URLEncoder.encode(fCategory,"UTF-8"));
    if (!fMinPrice.isEmpty()) baseQS.append("&minPrice=").append(java.net.URLEncoder.encode(fMinPrice,"UTF-8"));
    if (!fMaxPrice.isEmpty()) baseQS.append("&maxPrice=").append(java.net.URLEncoder.encode(fMaxPrice,"UTF-8"));
    if (!fCondition.isEmpty())baseQS.append("&condition=").append(java.net.URLEncoder.encode(fCondition,"UTF-8"));
    if (!fLocation.isEmpty()) baseQS.append("&location=").append(java.net.URLEncoder.encode(fLocation,"UTF-8"));
    if (!"newest".equals(fSortBy)) baseQS.append("&sortBy=").append(java.net.URLEncoder.encode(fSortBy,"UTF-8"));

    String[] catIcons = {"📱","⚡","💻","🚗","🏍️","🛋️","👗","📚","⚽","🏠","💼","🔧","🐾","📦"};
%>

<%-- ── FILTER OVERLAY ── --%>
<div id="filterOverlay" class="filter-overlay" onclick="closeFilterDrawer()"></div>

<%-- ── FILTER DRAWER ── --%>
<div id="filterDrawer" class="filter-drawer" role="dialog" aria-modal="true" aria-label="Product Filters">
    <div class="filter-drawer-header">
        <div class="filter-drawer-title">🔧 Filters</div>
        <button class="filter-drawer-close" onclick="closeFilterDrawer()" aria-label="Close filters">✕</button>
    </div>

    <form action="displayproducts" method="GET" id="filterForm">
        <div class="filter-drawer-body">

            <%-- Keyword --%>
            <div class="filter-section">
                <div class="filter-section-label">Keyword</div>
                <div class="search-input-wrap" style="flex:1;">
                    <span class="search-icon">🔍</span>
                    <input type="text" name="q" id="drawerQ"
                           value="<%= fQuery %>"
                           placeholder="Search products..."
                           autocomplete="off">
                    <button type="button" class="search-clear" onclick="clearDrawerSearch()" aria-label="Clear search">✕</button>
                </div>
            </div>

            <%-- Category --%>
            <div class="filter-section">
                <div class="filter-section-label">Category</div>
                <select name="category" id="drawerCat">
                    <option value="all" <%= fCategory.isEmpty() ? "selected" : "" %>>All Categories</option>
                    <% if (catList != null) { for (int ci = 0; ci < catList.length; ci++) { String cat = catList[ci]; %>
                    <option value="<%= cat %>" <%= cat.equals(fCategory) ? "selected" : "" %>><%= catIcons[ci] %> <%= cat %></option>
                    <% }} %>
                </select>
            </div>

            <%-- Price Range --%>
            <div class="filter-section">
                <div class="filter-section-label">Price Range (₹)</div>
                <div class="price-range-row">
                    <input type="number" name="minPrice" id="drawerMin"
                           placeholder="Min" value="<%= fMinPrice %>" min="0">
                    <input type="number" name="maxPrice" id="drawerMax"
                           placeholder="Max" value="<%= fMaxPrice %>" min="0">
                </div>
            </div>

            <%-- Condition --%>
            <div class="filter-section">
                <div class="filter-section-label">Condition</div>
                <select name="condition" id="drawerCond">
                    <option value="all" <%= fCondition.isEmpty() ? "selected" : "" %>>Any Condition</option>
                    <% if (condList != null) { for (String cond : condList) { %>
                    <option value="<%= cond %>" <%= cond.equals(fCondition) ? "selected" : "" %>><%= cond %></option>
                    <% }} %>
                </select>
            </div>

            <%-- Location --%>
            <div class="filter-section">
                <div class="filter-section-label">Location</div>
                <input type="text" name="location" id="drawerLoc"
                       placeholder="City or state..." value="<%= fLocation %>">
            </div>

            <%-- Sort By --%>
            <div class="filter-section">
                <div class="filter-section-label">Sort By</div>
                <select name="sortBy" id="drawerSort">
                    <option value="newest"    <%= "newest".equals(fSortBy)    ? "selected" : "" %>>⬆ Newest First</option>
                    <option value="oldest"    <%= "oldest".equals(fSortBy)    ? "selected" : "" %>>⬇ Oldest First</option>
                    <option value="price_asc" <%= "price_asc".equals(fSortBy) ? "selected" : "" %>>₹ Price: Low → High</option>
                    <option value="price_desc"<%= "price_desc".equals(fSortBy)? "selected" : "" %>>₹ Price: High → Low</option>
                    <option value="name_asc"  <%= "name_asc".equals(fSortBy)  ? "selected" : "" %>>🔤 Name: A–Z</option>
                </select>
            </div>
        </div>

        <div class="filter-drawer-footer">
            <button type="submit" class="btn btn-primary" id="applyFiltersBtn">Apply Filters ✓</button>
            <a href="displayproducts" class="btn btn-secondary" style="text-align:center;" id="clearAllBtn">Clear All Filters</a>
        </div>
    </form>
</div>

<%-- ── HEADER ── --%>
<%@ include file="fragments/header.jspf" %>

<%-- ── MAIN CONTENT ── --%>
<div class="marketplace-main">

    <%-- Error / message --%>
    <% if (request.getAttribute("filterError") != null) { %>
        <div class="filter-error-strip">⚠️ ${filterError}</div>
    <% } %>

    <%-- TOPBAR: Search + Filters + Sort --%>
    <form id="topSearchForm" action="displayproducts" method="GET" class="marketplace-topbar">
        <input type="hidden" name="category" value="<%= fCategory %>">
        <input type="hidden" name="condition" value="<%= fCondition %>">
        <input type="hidden" name="minPrice" value="<%= fMinPrice %>">
        <input type="hidden" name="maxPrice" value="<%= fMaxPrice %>">
        <input type="hidden" name="location" value="<%= fLocation %>">
        <input type="hidden" name="sortBy" value="<%= fSortBy %>">

        <div class="search-input-wrap" style="flex:1; min-width:200px;">
            <span class="search-icon">🔍</span>
            <input type="text" name="q" id="topSearchInput"
                   value="<%= fQuery %>"
                   placeholder="Search products, brands, locations..."
                   autocomplete="off"
                   class="<%= !fQuery.isEmpty() ? "has-value" : "" %>">
            <button type="button" class="search-clear" onclick="clearTopSearch()" aria-label="Clear">✕</button>
        </div>

        <button type="submit" class="btn btn-primary" id="searchSubmitBtn" style="flex-shrink:0;">Search</button>

        <button type="button" class="btn btn-secondary" id="filtersBtn" onclick="openFilterDrawer()"
                style="flex-shrink:0; position:relative;" aria-label="Open filters">
            🔧 Filters
            <% if (activeFilterCount > 0) { %>
                <span class="filter-count-badge" style="margin-left:4px;"><%= activeFilterCount %></span>
            <% } %>
        </button>

        <select name="sortByTop" class="sort-select-inline" id="topSortSelect"
                style="flex-shrink:0;"
                onchange="updateSortAndSubmit(this.value)">
            <option value="newest"    <%= "newest".equals(fSortBy)    ? "selected" : "" %>>⬆ Newest</option>
            <option value="oldest"    <%= "oldest".equals(fSortBy)    ? "selected" : "" %>>⬇ Oldest</option>
            <option value="price_asc" <%= "price_asc".equals(fSortBy) ? "selected" : "" %>>₹ Low→High</option>
            <option value="price_desc"<%= "price_desc".equals(fSortBy)? "selected" : "" %>>₹ High→Low</option>
            <option value="name_asc"  <%= "name_asc".equals(fSortBy)  ? "selected" : "" %>>🔤 A–Z</option>
        </select>
    </form>

    <%-- Active filter badges --%>
    <% if (anyFilter) { %>
    <div class="active-filters">
        <% if (!fQuery.isEmpty()) { %>
            <span class="active-filter-badge">🔍 "<%= fQuery %>" <a href="javascript:clearFilter('q')">✕</a></span>
        <% } %>
        <% if (!fCategory.isEmpty()) { %>
            <span class="active-filter-badge">🏷️ <%= fCategory %> <a href="javascript:clearFilter('category')">✕</a></span>
        <% } %>
        <% if (!fCondition.isEmpty()) { %>
            <span class="active-filter-badge">📦 <%= fCondition %> <a href="javascript:clearFilter('condition')">✕</a></span>
        <% } %>
        <% if (!fMinPrice.isEmpty() || !fMaxPrice.isEmpty()) { %>
            <span class="active-filter-badge">₹ <%= fMinPrice.isEmpty() ? "0" : fMinPrice %> – <%= fMaxPrice.isEmpty() ? "∞" : fMaxPrice %>
                <a href="javascript:clearPriceFilter()">✕</a></span>
        <% } %>
        <% if (!fLocation.isEmpty()) { %>
            <span class="active-filter-badge">📍 <%= fLocation %> <a href="javascript:clearFilter('location')">✕</a></span>
        <% } %>
        <a href="displayproducts" style="font-size:0.78rem; color:var(--danger); text-decoration:none; padding:4px 10px; border-radius:999px; border:1px solid rgba(239,68,68,0.3); white-space:nowrap; transition:var(--transition);">Clear All ✕</a>
    </div>
    <% } %>

    <%-- Results info --%>
    <div class="results-info">
        <strong><%= totalCount %> product<%= totalCount != 1 ? "s" : "" %></strong>
        <% if (!fCategory.isEmpty()) { %><span>· in <em><%= fCategory %></em></span><% } %>
        <% if (!fQuery.isEmpty()) { %><span>· matching "<em><%= fQuery %></em>"</span><% } %>
        <span>· Page <%= currentPage %> of <%= totalPages %></span>
    </div>

    <%-- ── PRODUCT GRID ── --%>
    <% if (products != null && !products.isEmpty()) { %>
    <div class="product-grid-v2" id="productGrid">
        <% for (Product product : products) {
            String dName = cleanName(product.getName());
            String dDate = fmtDate(product.getCreatedDate());
        %>
        <a href="productdetails?id=<%= product.getId() %>" class="pcard" id="product-<%= product.getId() %>">
            <div class="pcard-img-wrap">
                <% if (product.getImage() != null && product.getImage().length > 0) { %>
                    <img class="pcard-img" src="product-image?id=<%= product.getId() %>"
                         alt="<%= dName %>" loading="lazy">
                <% } else { %>
                    <div class="pcard-no-img">
                        <span class="no-img-icon">📷</span>
                        <span class="no-img-text">No Image</span>
                    </div>
                <% } %>
            </div>
            <div class="pcard-body">
                <div class="pcard-name" title="<%= dName %>"><%= dName %></div>
                <div class="pcard-price"><%= CurrencyFormatter.format(product.getPrice()) %></div>
                <div class="pcard-badges">
                    <% if (product.getCategory() != null && !product.getCategory().isEmpty()) { %>
                        <span class="pbadge pbadge-cat"><%= product.getCategory() %></span>
                    <% } %>
                    <% if (product.getProductCondition() != null && !product.getProductCondition().isEmpty()) { %>
                        <span class="pbadge pbadge-cond"><%= product.getProductCondition() %></span>
                    <% } %>
                </div>
                <% if (product.getLocation() != null && !product.getLocation().isEmpty()) { %>
                    <div class="pcard-meta">📍 <%= product.getLocation() %></div>
                <% } %>
            </div>
            <div class="pcard-footer">
                <span class="pcard-date"><% if (!dDate.isEmpty()) { %>📅 <%= dDate %><% } %></span>
                <span class="pcard-view-btn">View Details →</span>
            </div>
        </a>
        <% } %>
    </div>

    <%-- PAGINATION --%>
    <% if (totalPages > 1) { %>
    <nav class="pagination" id="paginationNav" aria-label="Product pages">
        <% if (currentPage > 1) { %>
            <a href="displayproducts?page=<%= currentPage - 1 %><%= baseQS %>" aria-label="Previous page">‹</a>
        <% } else { %>
            <span class="disabled" aria-hidden="true">‹</span>
        <% } %>

        <%
        int startPage = Math.max(1, currentPage - 2);
        int endPage   = Math.min(totalPages, currentPage + 2);
        if (startPage > 1) { %>
            <a href="displayproducts?page=1<%= baseQS %>">1</a>
            <% if (startPage > 2) { %><span style="border:none;background:transparent;color:var(--text-muted);">…</span><% } %>
        <% }
        for (int p = startPage; p <= endPage; p++) { %>
            <% if (p == currentPage) { %>
                <span class="active" aria-current="page"><%= p %></span>
            <% } else { %>
                <a href="displayproducts?page=<%= p %><%= baseQS %>"><%= p %></a>
            <% } %>
        <% }
        if (endPage < totalPages) {
            if (endPage < totalPages - 1) { %><span style="border:none;background:transparent;color:var(--text-muted);">…</span><% } %>
            <a href="displayproducts?page=<%= totalPages %><%= baseQS %>"><%= totalPages %></a>
        <% } %>

        <% if (currentPage < totalPages) { %>
            <a href="displayproducts?page=<%= currentPage + 1 %><%= baseQS %>" aria-label="Next page">›</a>
        <% } else { %>
            <span class="disabled" aria-hidden="true">›</span>
        <% } %>
    </nav>
    <% } %>

    <% } else { %>
    <%-- EMPTY STATE --%>
    <div class="empty-state" id="emptyState">
        <div class="empty-state-icon">🔍</div>
        <div class="empty-state-title">No products found</div>
        <div class="empty-state-desc">Try adjusting your filters, clearing your search, or exploring a different category.</div>
        <a href="displayproducts" class="btn btn-primary" style="margin-top:8px;" id="resetSearchBtn">Browse All Products</a>
    </div>
    <% } %>
</div>

<script>
    /* ── FILTER DRAWER ── */
    function openFilterDrawer() {
        document.getElementById('filterDrawer').classList.add('open');
        document.getElementById('filterOverlay').classList.add('open');
        document.body.classList.add('drawer-open');
        document.getElementById('drawerQ').focus();
    }

    function closeFilterDrawer() {
        document.getElementById('filterDrawer').classList.remove('open');
        document.getElementById('filterOverlay').classList.remove('open');
        document.body.classList.remove('drawer-open');
    }

    // Close on Escape
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeFilterDrawer();
    });

    // Apply filters — form submits naturally (page reloads)
    document.getElementById('filterForm').addEventListener('submit', function () {
        closeFilterDrawer();
    });

    /* ── SEARCH CLEAR ── */
    function clearTopSearch() {
        var input = document.getElementById('topSearchInput');
        input.value = '';
        input.classList.remove('has-value');
        document.getElementById('topSearchForm').submit();
    }

    function clearDrawerSearch() {
        var input = document.getElementById('drawerQ');
        input.value = '';
        input.focus();
    }

    /* ── FILTER CLEAR HELPERS ── */
    function clearFilter(name) {
        var url = new URL(window.location.href);
        url.searchParams.delete(name);
        url.searchParams.delete('page');
        window.location.href = url.toString();
    }

    function clearPriceFilter() {
        var url = new URL(window.location.href);
        url.searchParams.delete('minPrice');
        url.searchParams.delete('maxPrice');
        url.searchParams.delete('page');
        window.location.href = url.toString();
    }

    /* ── TOP SORT SELECT ── */
    function updateSortAndSubmit(val) {
        var url = new URL(window.location.href);
        url.searchParams.set('sortBy', val);
        url.searchParams.delete('page');
        window.location.href = url.toString();
    }

    /* ── ENTER KEY on top search ── */
    document.getElementById('topSearchInput').addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); document.getElementById('topSearchForm').submit(); }
    });

    /* ── Show clear button when input has value ── */
    document.getElementById('topSearchInput').addEventListener('input', function () {
        this.classList.toggle('has-value', this.value.length > 0);
    });
</script>
</body>
</html>
