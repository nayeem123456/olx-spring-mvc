<%@page import="mvc_olx.dto.Product"%>
<%@page import="mvc_olx.dto.Customer"%>
<%@page import="mvc_olx.helper.CurrencyFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Details – OLX Marketplace</title>
    <%@ include file="fragments/head-scripts.jspf" %>
    <style>
        .details-container {
            display: grid;
            grid-template-columns: 1fr;
            gap: 32px;
            margin-top: 20px;
        }
        @media(min-width: 768px) {
            .details-container {
                grid-template-columns: 1.2fr 1fr;
            }
        }
        .image-gallery {
            background: rgba(15,23,42,0.4);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 300px;
            position: relative;
            overflow: hidden;
        }
        .large-img {
            max-width: 100%;
            max-height: 400px;
            object-fit: contain;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            transition: var(--transition);
        }
        .large-img:hover {
            transform: scale(1.02);
        }
        .placeholder-gallery {
            width: 100%;
            height: 300px;
            background: var(--placeholder-bg);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 12px;
            border-radius: 12px;
            color: var(--text-muted);
        }
        .info-panel {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        .product-header {
            border-bottom: 1px solid var(--card-border);
            padding-bottom: 16px;
        }
        .product-title {
            font-size: 2rem;
            font-weight: 800;
            margin-bottom: 8px;
            text-align: left;
            background: none;
            color: var(--text-primary);
        }
        .price-badge {
            font-size: 2.2rem;
            font-weight: 800;
            color: var(--success);
            display: flex;
            align-items: baseline;
            gap: 6px;
        }
        .price-badge span {
            font-size: 0.95rem;
            font-weight: 400;
            color: var(--text-secondary);
        }
        .meta-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            background: rgba(255,255,255,0.02);
            border: 1px solid var(--card-border);
            padding: 20px;
            border-radius: 16px;
        }
        .meta-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .meta-label {
            font-size: 0.8rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .meta-value {
            font-weight: 600;
            color: var(--text-primary);
            font-size: 0.95rem;
        }
        .seller-card {
            border: 1px solid var(--card-border);
            background: rgba(139,92,246,0.05);
            padding: 20px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .seller-avatar {
            width: 48px;
            height: 48px;
            background: var(--primary);
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 1.4rem;
        }
        .seller-info {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        .seller-name {
            font-weight: 700;
            color: var(--text-primary);
        }
        .seller-id {
            font-size: 0.82rem;
            color: var(--text-secondary);
        }
        .desc-section {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .section-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--text-primary);
        }
        .desc-text {
            color: var(--text-secondary);
            font-size: 0.95rem;
            line-height: 1.6;
            white-space: pre-line;
        }
        .badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 0.8rem;
            font-weight: 700;
            margin-bottom: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
        .badge-available {
            background: rgba(16, 185, 129, 0.15);
            color: #34d399;
            border: 1px solid rgba(16, 185, 129, 0.3);
        }
        .badge-sold {
            background: rgba(239, 68, 68, 0.15);
            color: #f87171;
            border: 1px solid rgba(239, 68, 68, 0.3);
        }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <%
        Product product = (Product) request.getAttribute("product");
        Customer seller = (Customer) request.getAttribute("seller");
        Customer loggedInUser = (Customer) session.getAttribute("customer");
    %>
    <div class="page">
        <% if (product == null) { %>
            <div class="card">
                <div class="message message-error">⚠️ Product details not found.</div>
                <a href="displayproducts" class="btn btn-secondary btn-block">Back to Marketplace</a>
            </div>
        <% } else { %>
            <div class="card">
                <div class="details-container">
                    <!-- Image Column -->
                    <div class="image-gallery">
                        <% if (Product.STATUS_SOLD.equals(product.getStatus())) { %>
                            <span class="badge badge-sold" style="position: absolute; top: 20px; right: 20px; z-index: 10;">SOLD</span>
                        <% } else { %>
                            <span class="badge badge-available" style="position: absolute; top: 20px; right: 20px; z-index: 10;">AVAILABLE</span>
                        <% } %>

                        <% if (product.getImage() != null && product.getImage().length > 0) { %>
                            <img class="large-img" src="product-image?id=<%= product.getId() %>" alt="<%= product.getName() %>">
                        <% } else { %>
                            <div class="placeholder-gallery">
                                <span style="font-size: 3rem;">📷</span>
                                <span style="font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.7;">No Image Available</span>
                            </div>
                        <% } %>
                    </div>

                    <!-- Details Column -->
                    <div class="info-panel">
                        <div class="product-header">
                            <h1 class="product-title"><%= product.getName() %></h1>
                            <div class="price-badge">
                                <%= CurrencyFormatter.format(product.getPrice()) %>
                                <span>Fixed Price</span>
                            </div>
                        </div>

                        <!-- Metadata Grid -->
                        <div class="meta-grid">
                            <div class="meta-item">
                                <span class="meta-label">Category</span>
                                <span class="meta-value"><%= product.getCategory() != null ? product.getCategory() : "General" %></span>
                            </div>
                            <div class="meta-item">
                                <span class="meta-label">Condition</span>
                                <span class="meta-value"><%= product.getProductCondition() != null ? product.getProductCondition() : "N/A" %></span>
                            </div>
                            <div class="meta-item">
                                <span class="meta-label">Location</span>
                                <span class="meta-value">📍 <%= product.getLocation() != null ? product.getLocation() : "N/A" %></span>
                            </div>
                            <div class="meta-item">
                                <span class="meta-label">Date Posted</span>
                                <span class="meta-value">📅 <%= product.getCreatedDate() != null ? product.getCreatedDate() : "N/A" %></span>
                            </div>
                        </div>

                        <!-- Description -->
                        <div class="desc-section">
                            <div class="section-title">Description</div>
                            <p class="desc-text"><%= product.getDescription() != null ? product.getDescription() : "No description provided." %></p>
                        </div>

                        <!-- Seller Info -->
                        <% if (seller != null) { %>
                            <div class="seller-card">
                                <div class="seller-avatar">
                                    <%= seller.getName().substring(0, 1).toUpperCase() %>
                                </div>
                                <div class="seller-info">
                                    <span class="seller-name"><%= seller.getName() %></span>
                                    <span class="seller-id" style="font-size:0.78rem; color:var(--text-muted);">Verified Seller ✅</span>
                                </div>
                            </div>
                        <% } %>

                        <!-- Action Button -->
                        <div style="margin-top: 10px;">
                            <% if (Product.STATUS_SOLD.equals(product.getStatus())) { %>
                                <button class="btn btn-secondary btn-block" style="opacity: 0.6; cursor: not-allowed;" disabled>Product Sold Out ❌</button>
                            <% } else if (loggedInUser == null) { %>
                                <a href="Login.jsp" class="btn btn-primary btn-block">Login to Buy Now</a>
                            <% } else if (loggedInUser.getId() == product.getSold()) { %>
                                <a href="editproduct?id=<%= product.getId() %>" class="btn btn-primary btn-block">Edit Product Listing ✏️</a>
                            <% } else { %>
                                <a href="buy?id=<%= product.getId() %>" class="btn btn-success btn-block"
                                   onclick="return confirm('Do you want to buy this product for <%= CurrencyFormatter.format(product.getPrice()) %>? The amount will be deducted from your wallet.');">Buy Now 🛒</a>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div style="margin-top: 32px; border-top: 1px solid var(--card-border); padding-top: 20px;">
                    <a href="displayproducts" class="btn btn-secondary">← Back to Marketplace</a>
                </div>
            </div>
        <% } %>
    </div>
</body>
</html>
