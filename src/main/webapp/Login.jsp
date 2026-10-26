<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – OLX Marketplace</title>
    <meta name="description" content="Login to your OLX account to buy, sell and manage your wallet.">
    <%@ include file="fragments/head-scripts.jspf" %>
    <style>
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .input-icon-wrap { position: relative; }
        .input-icon-wrap .icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 1.1rem;
            pointer-events: none;
        }
        .input-icon-wrap input { padding-left: 42px; }
        .field-error {
            font-size: 0.82rem;
            color: #f87171;
            display: none;
            margin-top: 2px;
        }
        .input-invalid { border-color: #ef4444 !important; box-shadow: 0 0 0 3px rgba(239,68,68,0.15) !important; }
        .login-footer {
            text-align: center;
            margin-top: 20px;
            color: var(--text-secondary);
            font-size: 0.9rem;
        }
        .login-footer a { color: var(--primary); text-decoration: none; font-weight: 600; }
        .login-footer a:hover { color: var(--primary-hover); }
        .btn-row { display: flex; gap: 12px; }
        .btn-row .btn { flex: 1; }
    </style>
</head>
<body>
    <%@ include file="fragments/header.jspf" %>
    <div class="page" style="max-width: 460px;">
        <div class="card">
            <h1>Welcome Back 👋</h1>
            <p class="subtitle">Sign in to your OLX account.</p>

            <% if(request.getAttribute("msg") != null) { %>
                <div class="message message-error">${msg}</div>
            <% } %>

            <form action="login" method="post" class="stack" id="loginForm" novalidate>
                <div class="form-group">
                    <label for="cid">Customer ID</label>
                    <div class="input-icon-wrap">
                        <span class="icon">🪪</span>
                        <input type="number" id="cid" name="cid" placeholder="Enter your Customer ID" required min="1">
                    </div>
                    <span class="field-error" id="cid-error">Please enter a valid Customer ID.</span>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-icon-wrap">
                        <span class="icon">🔑</span>
                        <input type="password" id="password" name="password" placeholder="Enter your password" required minlength="4" style="padding-right: 42px;">
                        <span class="toggle-password" id="togglePassword" style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); cursor: pointer; font-size: 1.1rem; user-select: none;">👁️</span>
                    </div>
                    <span class="field-error" id="pass-error">Password must be at least 4 characters.</span>
                </div>
                <div class="btn-row">
                    <button type="reset" class="btn btn-danger" onclick="clearErrors()">Cancel</button>
                    <button type="submit" class="btn btn-primary" id="loginBtn">Login →</button>
                </div>
            </form>

            <div class="login-footer">
                Don't have an account? <a href="Signup.jsp">Create one</a>
            </div>
            <div style="margin-top: 14px;">
                <a href="Home.jsp" class="btn btn-secondary btn-block">← Back to Home</a>
            </div>
        </div>
    </div>

    <script>
        const loginForm = document.getElementById('loginForm');
        const cidInput = document.getElementById('cid');
        const passInput = document.getElementById('password');

        loginForm.addEventListener('submit', function(e) {
            let valid = true;
            clearErrors();

            if (!cidInput.value || parseInt(cidInput.value) < 1) {
                showError('cid-error', cidInput);
                valid = false;
            }
            if (!passInput.value || passInput.value.length < 4) {
                showError('pass-error', passInput);
                valid = false;
            }
            if (!valid) e.preventDefault();
        });

        function showError(errorId, input) {
            document.getElementById(errorId).style.display = 'block';
            input.classList.add('input-invalid');
        }

        function clearErrors() {
            document.querySelectorAll('.field-error').forEach(e => e.style.display = 'none');
            document.querySelectorAll('.input-invalid').forEach(e => e.classList.remove('input-invalid'));
        }

        // Real-time validation
        cidInput.addEventListener('input', () => {
            if (cidInput.value && parseInt(cidInput.value) > 0) {
                cidInput.classList.remove('input-invalid');
                document.getElementById('cid-error').style.display = 'none';
            }
        });
        passInput.addEventListener('input', () => {
            if (passInput.value.length >= 4) {
                passInput.classList.remove('input-invalid');
                document.getElementById('pass-error').style.display = 'none';
            }
        });

        const togglePassword = document.getElementById('togglePassword');
        togglePassword.addEventListener('click', function () {
            const type = passInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passInput.setAttribute('type', type);
            togglePassword.textContent = type === 'password' ? '👁️' : '🙈';
        });
    </script>
</body>
</html>
