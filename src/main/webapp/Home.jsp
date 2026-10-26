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
        return new java.text.SimpleDateFormat("d MMM yyyy").format(d);
    }
%>
<html data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OLX India – Buy &amp; Sell Anything</title>
    <meta name="description" content="India's #1 marketplace – Buy, sell electronics, cars, bikes, furniture and more with OLX. Safe, fast and free.">
    <%@ include file="fragments/head-scripts.jspf" %>
    <style>
        /* ─── Hero ─── */
        .hero {
            text-align: center;
            padding: 56px 20px 40px;
        }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(139,92,246,0.14);
            border: 1px solid rgba(139,92,246,0.28);
            color: var(--primary-hover);
            font-size: 0.78rem;
            font-weight: 700;
            padding: 6px 18px;
            border-radius: 999px;
            margin-bottom: 20px;
            letter-spacing: 0.6px;
            text-transform: uppercase;
        }
        [data-theme="light"] .hero-badge {
            background: #EDE9FE; color: #7C3AED; border-color: #DDD6FE;
        }
        .hero h1 {
            font-size: clamp(2rem, 5vw, 3.2rem);
            margin-bottom: 14px;
            background: linear-gradient(135deg, var(--text-primary) 30%, var(--primary));
            -webkit-background-clip: text; background-clip: text; color: transparent;
            line-height: 1.15;
        }
        .hero-sub {
            font-size: 1.05rem;
            color: var(--text-secondary);
            max-width: 480px;
            margin: 0 auto 36px;
        }

        /* ─── Hero Search ─── */
        .hero-search-form {
            display: flex;
            max-width: 580px;
            margin: 0 auto 36px;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid rgba(139,92,246,0.35);
            box-shadow: 0 8px 32px rgba(139,92,246,0.15);
            background: var(--card-bg);
        }
        .hero-search-wrap {
            flex: 1;
            position: relative;
            display: flex;
            align-items: center;
        }
        .hero-search-wrap .hero-icon {
            position: absolute; left: 16px;
            color: var(--text-muted); font-size: 1rem; pointer-events: none;
        }
        .hero-search-input {
            flex: 1;
            padding: 16px 40px 16px 42px;
            border: none;
            background: transparent;
            color: var(--text-primary);
            font-size: 1rem;
            font-family: inherit;
            outline: none;
            width: 100%;
        }
        .hero-search-input::placeholder { color: var(--placeholder-fg); }
        .hero-clear-btn {
            position: absolute; right: 10px;
            background: none; border: none;
            color: var(--text-muted); cursor: pointer;
            font-size: 0.9rem; padding: 4px 6px;
            border-radius: 6px; transition: var(--transition);
            display: none; font-family: inherit;
        }
        .hero-clear-btn:hover { color: var(--danger); background: rgba(239,68,68,0.1); }
        .hero-search-input:not(:placeholder-shown) ~ .hero-clear-btn { display: block; }
        .hero-search-btn {
            padding: 0 28px;
            background: linear-gradient(135deg, var(--primary), #6366f1);
            color: #fff; border: none;
            font-size: 0.95rem; font-weight: 700;
            cursor: pointer; font-family: inherit;
            transition: opacity 0.2s; white-space: nowrap;
            letter-spacing: 0.2px;
        }
        .hero-search-btn:hover { opacity: 0.88; }

        /* ─── CTA strip ─── */
        .hero-cta { display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; margin-bottom: 8px; }

        /* ─── Stats strip ─── */
        .stats-strip {
            display: flex;
            justify-content: center;
            gap: 32px;
            padding: 20px 24px;
            background: var(--secondary-bg);
            border: 1px solid var(--card-border);
            border-radius: 14px;
            margin-bottom: 40px;
            flex-wrap: wrap;
        }
        .stat-item { text-align: center; }
        .stat-num { font-size: 1.5rem; font-weight: 800; color: var(--primary-hover); line-height: 1; }
        [data-theme="light"] .stat-num { color: #7C3AED; }
        .stat-lbl { font-size: 0.75rem; color: var(--text-muted); margin-top: 3px; font-weight: 500; }

        /* ─── Category Grid ─── */
        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 12px;
            margin-bottom: 48px;
        }
        .category-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 14px;
            padding: 18px 10px;
            text-align: center;
            cursor: pointer;
            text-decoration: none;
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 9px;
        }
        .category-card:hover {
            background: rgba(139,92,246,0.1);
            border-color: rgba(139,92,246,0.35);
            transform: translateY(-4px);
            box-shadow: var(--shadow-sm), var(--shadow-glow);
        }
        [data-theme="light"] .category-card:hover {
            background: #EDE9FE; border-color: #DDD6FE;
        }
        .category-card:hover .cat-icon { transform: scale(1.15) rotate(-3deg); }
        .cat-icon { font-size: 1.8rem; line-height: 1; transition: transform 0.3s ease; }
        .cat-label { font-size: 0.72rem; font-weight: 700; color: var(--text-secondary); letter-spacing: 0.2px; }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <%
        List<Product> latestProducts = (List<Product>) request.getAttribute("latestProducts");
        String[] categoryIcons = {"📱","⚡","💻","🚗","🏍️","🛋️","👗","📚","⚽","🏠","💼","🔧","🐾","📦"};
        String[] categoryNames = {"Mobiles","Electronics","Computers & Laptops","Cars","Bikes","Furniture","Fashion","Books","Sports","Home Appliances","Jobs","Services","Pets","Others"};
    %>
    <div class="page" style="max-width:1100px;">
        <div class="card">
            <% if (request.getAttribute("msg") != null) { %>
                <div class="message message-<%= request.getAttribute("msg").toString().toLowerCase().contains("success") || request.getAttribute("msg").toString().toLowerCase().contains("purchased") ? "success" : "error" %>">
                    ${msg}
                </div>
            <% } %>

            <%-- ── HERO ── --%>
            <div class="hero">
                <div class="hero-badge">✨ India's #1 Marketplace</div>
                <h1>Buy &amp; Sell<br>Anything in India</h1>
                <p class="hero-sub">Discover great deals from verified sellers near you – electronics, vehicles, furniture and more.</p>

                <form class="hero-search-form" action="displayproducts" method="GET" id="heroSearchForm">
                    <div class="hero-search-wrap">
                        <span class="hero-icon">🔍</span>
                        <input type="text" name="q" class="hero-search-input"
                               placeholder="Search products, brands, locations..."
                               id="heroSearchInput" autocomplete="off">
                        <button type="button" class="hero-clear-btn" id="heroClearBtn" onclick="clearHeroSearch()">✕</button>
                    </div>
                    <button type="submit" class="hero-search-btn">Search</button>
                </form>

                <div class="hero-cta">
                    <a href="displayproducts" class="btn btn-success" id="browse-all-btn">🛒 Browse All</a>
                    <% if (session.getAttribute("customer") == null) { %>
                        <a href="Login.jsp" class="btn btn-primary" id="login-btn">Login</a>
                        <a href="Signup.jsp" class="btn btn-secondary" id="signup-btn">Sign Up</a>
                    <% } else { %>
                        <a href="AddProduct.jsp" class="btn btn-primary" id="sell-btn">+ Sell a Product</a>
                        <a href="wallet" class="btn btn-secondary" id="wallet-btn">💳 My Wallet</a>
                    <% } %>
                </div>
            </div>

            <%-- Stats strip --%>
            <div class="stats-strip">
                <div class="stat-item"><div class="stat-num">14</div><div class="stat-lbl">Categories</div></div>
                <div class="stat-item"><div class="stat-num">100+</div><div class="stat-lbl">Active Listings</div></div>
                <div class="stat-item"><div class="stat-num">🇮🇳</div><div class="stat-lbl">India Only</div></div>
                <div class="stat-item"><div class="stat-num">Free</div><div class="stat-lbl">To List &amp; Browse</div></div>
            </div>

            <hr class="divider">

            <%-- ── CATEGORIES ── --%>
            <div class="section-heading">🏷️ Browse by Category <span class="section-sub">– Find what you're looking for</span></div>
            <div class="category-grid" id="categoryGrid">
                <% for (int ci = 0; ci < categoryNames.length; ci++) { %>
                <a href="displayproducts?category=<%= java.net.URLEncoder.encode(categoryNames[ci], "UTF-8") %>"
                   class="category-card"
                   id="cat-<%= categoryNames[ci].toLowerCase().replace(" ", "-").replace("&", "and") %>">
                    <span class="cat-icon"><%= categoryIcons[ci] %></span>
                    <span class="cat-label"><%= categoryNames[ci] %></span>
                </a>
                <% } %>
            </div>

            <hr class="divider">

            <%-- ── LATEST PRODUCTS ── --%>
            <% if (latestProducts != null && !latestProducts.isEmpty()) { %>
            <div class="section-heading">🆕 Latest Listings <span class="section-sub">– Freshly added</span></div>
            <div class="product-grid-v2" id="latestProductsGrid">
                <% for (Product product : latestProducts) {
                    String dName = cleanName(product.getName());
                    String dDate = fmtDate(product.getCreatedDate());
                %>
                <a href="productdetails?id=<%= product.getId() %>" class="pcard" id="latest-<%= product.getId() %>">
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
                        <span class="pcard-view-btn">View →</span>
                    </div>
                </a>
                <% } %>
            </div>
            <div style="text-align:center; margin-top:24px; margin-bottom:8px;">
                <a href="displayproducts" class="btn btn-secondary" id="view-all-btn">View All Products →</a>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        function clearHeroSearch() {
            var input = document.getElementById('heroSearchInput');
            input.value = '';
            input.focus();
        }
        document.getElementById('heroSearchInput').addEventListener('keydown', function(e) {
            if (e.key === 'Enter') { e.preventDefault(); document.getElementById('heroSearchForm').submit(); }
        });
    </script>
</body>
</html>
