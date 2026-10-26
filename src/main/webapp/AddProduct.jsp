<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Product – OLX Marketplace</title>
    <meta name="description" content="List your product on OLX Marketplace with image, name and price.">
    <%@ include file="fragments/head-scripts.jspf" %>
    <style>
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .input-icon-wrap { position: relative; }
        .input-icon-wrap .icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%); font-size: 1.1rem; pointer-events: none;
        }
        .input-icon-wrap input { padding-left: 42px; }
        .field-error { font-size: 0.82rem; color: #f87171; display: none; margin-top: 2px; }
        .input-invalid { border-color: #ef4444 !important; box-shadow: 0 0 0 3px rgba(239,68,68,0.15) !important; }

        /* Image upload preview */
        .upload-zone {
            border: 2px dashed var(--card-border);
            border-radius: 16px;
            padding: 32px 20px;
            text-align: center;
            cursor: pointer;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }
        .upload-zone:hover { border-color: var(--primary); background: rgba(139,92,246,0.05); }
        .upload-zone.drag-over { border-color: var(--primary); background: rgba(139,92,246,0.1); }
        .upload-icon { font-size: 2.5rem; margin-bottom: 10px; }
        .upload-label { font-weight: 600; color: var(--text-primary); margin-bottom: 4px; }
        .upload-hint { font-size: 0.85rem; color: var(--text-secondary); }
        .upload-zone input[type="file"] {
            position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; height: 100%;
        }
        .preview-img {
            max-width: 100%;
            max-height: 220px;
            border-radius: 12px;
            margin-top: 12px;
            display: none;
            object-fit: contain;
            box-shadow: 0 4px 16px rgba(0,0,0,0.3);
        }
        .file-info {
            font-size: 0.85rem;
            color: var(--success);
            margin-top: 8px;
            display: none;
        }
        .btn-row { display: flex; gap: 12px; }
        .btn-row .btn { flex: 1; }
        .price-prefix {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            font-weight: 700; color: var(--success); font-size: 1.1rem;
        }
        .price-input { padding-left: 36px !important; }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <div class="page" style="max-width: 680px;">
        <%
        if(session.getAttribute("customer") == null) {
        %>
            <div class="card">
                <div class="message message-error">⚠️ Invalid session. Please log in to sell products.</div>
                <a href="Login.jsp" class="btn btn-primary btn-block">Go to Login</a>
        <% } else { %>
            <div class="card">
                <h1>Sell a Product 🏷️</h1>
                <p class="subtitle">List your item with a description, price, and photo.</p>
                <% if (request.getAttribute("msg") != null) { %>
                    <div class="message message-error">
                        ${msg}
                    </div>
                <% } %>
                <form action="addproduct" method="post" enctype="multipart/form-data" class="stack" id="addProductForm" novalidate>
                    <div class="form-group">
                        <label for="pname">Product Name</label>
                        <div class="input-icon-wrap">
                            <span class="icon">📦</span>
                            <input type="text" id="pname" name="pname" placeholder="e.g. iPhone 13 Pro, Nike Shoes..." value="${pname}" required minlength="2">
                        </div>
                        <span class="field-error" id="name-error">Product name must be at least 2 characters.</span>
                    </div>

                    <div class="row">
                        <div class="form-group" style="flex: 1; min-width: 200px;">
                            <label for="pprice">Asking Price (₹)</label>
                            <div class="input-icon-wrap">
                                <span class="price-prefix">₹</span>
                                <input type="number" id="pprice" name="pprice" placeholder="0.00" step="0.01" min="1" value="${pprice}" required class="price-input">
                            </div>
                            <span class="field-error" id="price-error">Please enter a valid price greater than 0.</span>
                        </div>

                        <div class="form-group" style="flex: 1; min-width: 200px;">
                            <label for="category">Category</label>
                            <select id="category" name="category" required class="sort-select" style="width:100%; border-radius:12px; height: 50px;">
                                <option value="">Select a Category</option>
                                <option value="Mobiles"              ${category == 'Mobiles'              ? 'selected' : ''}>📱 Mobiles</option>
                                <option value="Electronics"          ${category == 'Electronics'          ? 'selected' : ''}>⚡ Electronics</option>
                                <option value="Computers & Laptops"  ${category == 'Computers & Laptops'  ? 'selected' : ''}>💻 Computers &amp; Laptops</option>
                                <option value="Cars"                 ${category == 'Cars'                 ? 'selected' : ''}>🚗 Cars</option>
                                <option value="Bikes"                ${category == 'Bikes'                ? 'selected' : ''}>🏍️ Bikes</option>
                                <option value="Furniture"            ${category == 'Furniture'            ? 'selected' : ''}>🛋️ Furniture</option>
                                <option value="Fashion"              ${category == 'Fashion'              ? 'selected' : ''}>👗 Fashion</option>
                                <option value="Books"                ${category == 'Books'                ? 'selected' : ''}>📚 Books</option>
                                <option value="Sports"               ${category == 'Sports'               ? 'selected' : ''}>⚽ Sports</option>
                                <option value="Home Appliances"      ${category == 'Home Appliances'      ? 'selected' : ''}>🏠 Home Appliances</option>
                                <option value="Jobs"                 ${category == 'Jobs'                 ? 'selected' : ''}>💼 Jobs</option>
                                <option value="Services"             ${category == 'Services'             ? 'selected' : ''}>🔧 Services</option>
                                <option value="Pets"                 ${category == 'Pets'                 ? 'selected' : ''}>🐾 Pets</option>
                                <option value="Others"               ${category == 'Others'               ? 'selected' : ''}>📦 Others</option>
                            </select>
                            <span class="field-error" id="category-error">Please select a category.</span>
                        </div>
                    </div>

                    <div class="row">
                        <div class="form-group" style="flex: 1; min-width: 200px;">
                            <label for="condition">Condition</label>
                            <select id="condition" name="condition" required class="sort-select" style="width:100%; border-radius:12px; height: 50px;">
                                <option value="">Select Condition</option>
                                <option value="New"      ${condition == 'New'      ? 'selected' : ''}>✨ New</option>
                                <option value="Like New" ${condition == 'Like New' ? 'selected' : ''}>👌 Like New</option>
                                <option value="Good"     ${condition == 'Good'     ? 'selected' : ''}>✅ Good</option>
                                <option value="Fair"     ${condition == 'Fair'     ? 'selected' : ''}>🔄 Fair</option>
                                <option value="Used"     ${condition == 'Used'     ? 'selected' : ''}>📦 Used</option>
                            </select>
                            <span class="field-error" id="condition-error">Please select product condition.</span>
                        </div>

                        <div class="form-group" style="flex: 1; min-width: 200px;">
                            <label for="location">Location</label>
                            <div class="input-icon-wrap">
                                <span class="icon">📍</span>
                                <input type="text" id="location" name="location" placeholder="e.g. New York, Bangalore..." value="${location}" required>
                            </div>
                            <span class="field-error" id="location-error">Location cannot be empty.</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" placeholder="Write details about the product..." required rows="4" style="resize:vertical; min-height: 100px;">${description}</textarea>
                        <span class="field-error" id="description-error">Description cannot be empty.</span>
                    </div>

                    <div class="form-group">
                        <label>Product Image</label>
                        <div class="upload-zone" id="uploadZone">
                            <div class="upload-icon">📸</div>
                            <div class="upload-label">Click or drag & drop your image here</div>
                            <div class="upload-hint">Supports JPG, PNG, WEBP (max 5 MB)</div>
                            <input type="file" id="pimage" name="pimage" accept="image/*" required>
                        </div>
                        <img id="previewImg" class="preview-img" alt="Image preview">
                        <div class="file-info" id="fileInfo">✅ Image selected</div>
                        <span class="field-error" id="img-error">Please select a valid image file (max 5 MB).</span>
                    </div>

                    <div class="btn-row">
                        <button type="reset" class="btn btn-danger" onclick="clearForm()">Cancel</button>
                        <button type="submit" class="btn btn-primary">Put on Sale 🚀</button>
                    </div>
                </form>

                <div style="margin-top: 14px;">
                    <a href="home" class="btn btn-secondary btn-block">← Back to Home</a>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        const fileInput = document.getElementById('pimage');
        const previewImg = document.getElementById('previewImg');
        const fileInfo = document.getElementById('fileInfo');
        const uploadZone = document.getElementById('uploadZone');

        fileInput.addEventListener('change', handleFile);

        // Drag & drop support
        uploadZone.addEventListener('dragover', (e) => { e.preventDefault(); uploadZone.classList.add('drag-over'); });
        uploadZone.addEventListener('dragleave', () => uploadZone.classList.remove('drag-over'));
        uploadZone.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadZone.classList.remove('drag-over');
            if (e.dataTransfer.files.length) {
                fileInput.files = e.dataTransfer.files;
                handleFile();
            }
        });

        function handleFile() {
            const file = fileInput.files[0];
            if (!file) return;
            if (file.size > 5 * 1024 * 1024) {
                document.getElementById('img-error').textContent = '❌ File too large. Max 5 MB allowed.';
                document.getElementById('img-error').style.display = 'block';
                previewImg.style.display = 'none';
                fileInfo.style.display = 'none';
                return;
            }
            document.getElementById('img-error').style.display = 'none';
            const reader = new FileReader();
            reader.onload = e => {
                previewImg.src = e.target.result;
                previewImg.style.display = 'block';
            };
            reader.readAsDataURL(file);
            fileInfo.textContent = '✅ ' + file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)';
            fileInfo.style.display = 'block';
        }

        document.getElementById('addProductForm').addEventListener('submit', function(e) {
            let valid = true;
            document.querySelectorAll('.field-error').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.input-invalid').forEach(el => el.classList.remove('input-invalid'));

            const name = document.getElementById('pname');
            const price = document.getElementById('pprice');
            const img = document.getElementById('pimage');
            const category = document.getElementById('category');
            const condition = document.getElementById('condition');
            const location = document.getElementById('location');
            const description = document.getElementById('description');

            if (!name.value || name.value.trim().length < 2) {
                document.getElementById('name-error').style.display = 'block';
                name.classList.add('input-invalid'); valid = false;
            }
            if (!price.value || parseFloat(price.value) <= 0) {
                document.getElementById('price-error').style.display = 'block';
                price.classList.add('input-invalid'); valid = false;
            }
            if (!category.value) {
                document.getElementById('category-error').style.display = 'block';
                category.classList.add('input-invalid'); valid = false;
            }
            if (!condition.value) {
                document.getElementById('condition-error').style.display = 'block';
                condition.classList.add('input-invalid'); valid = false;
            }
            if (!location.value || location.value.trim().length === 0) {
                document.getElementById('location-error').style.display = 'block';
                location.classList.add('input-invalid'); valid = false;
            }
            if (!description.value || description.value.trim().length === 0) {
                document.getElementById('description-error').style.display = 'block';
                description.classList.add('input-invalid'); valid = false;
            }
            if (!img.files || !img.files.length) {
                document.getElementById('img-error').style.display = 'block';
                document.getElementById('img-error').textContent = 'Please select a product image.';
                valid = false;
            }
            if (!valid) e.preventDefault();
        });

        function clearForm() {
            previewImg.style.display = 'none';
            fileInfo.style.display = 'none';
            document.querySelectorAll('.field-error').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.input-invalid').forEach(el => el.classList.remove('input-invalid'));
        }
    </script>
</body>
</html>
