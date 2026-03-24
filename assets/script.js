const page = document.body.dataset.page;
const nav = document.querySelector(".nav");
const navToggle = document.querySelector(".nav-toggle");

if (nav && navToggle) {
  navToggle.addEventListener("click", () => {
    const isOpen = nav.classList.toggle("is-open");
    navToggle.setAttribute("aria-expanded", String(isOpen));
  });
}

document.querySelectorAll(".nav a").forEach((link) => {
  const href = link.getAttribute("href");
  if ((page === "home" && href === "index.html") || href === `${page}.html`) {
    link.classList.add("is-current");
  }
});

document.querySelectorAll(".faq-question").forEach((button) => {
  button.addEventListener("click", () => {
    button.parentElement.classList.toggle("is-open");
  });
});

const madeCustomsGrid = document.querySelector("#made-customs-grid");
const previousWorkGrid = document.querySelector("#previous-work-grid");

function renderGallery(target, products, emptyTitle, emptyText, typeLabel, showPrice) {
  if (!target) {
    return;
  }

  if (!products.length) {
    target.innerHTML = `
      <article class="catalog-card empty-state">
        <div>
          <span class="product-type">No Products Yet</span>
          <h2>${emptyTitle}</h2>
          <p>${emptyText}</p>
        </div>
      </article>
    `;
    return;
  }

  target.innerHTML = products
    .map(
      (product) => `
        <article class="catalog-card">
          <img class="catalog-thumb" src="${product.image}" alt="${product.name}">
          <span class="product-type">${typeLabel}</span>
          <h2>${product.name}</h2>
          <p>${product.description}</p>
          <div class="product-meta">
            <strong>${showPrice ? product.price : product.label}</strong>
            <span>${product.status}</span>
          </div>
        </article>
      `
    )
    .join("");
}

renderGallery(
  madeCustomsGrid,
  Array.isArray(window.MADE_CUSTOMS_PRODUCTS) ? window.MADE_CUSTOMS_PRODUCTS : [],
  "New customs will be listed here soon.",
  "Check back later or place a direct order through the contact page.",
  "Made Custom",
  true
);

renderGallery(
  previousWorkGrid,
  Array.isArray(window.PREVIOUS_WORK_ITEMS) ? window.PREVIOUS_WORK_ITEMS : [],
  "Add PNG files to the previous work folder.",
  "Finished pieces will appear here automatically as portfolio examples.",
  "Previous Work",
  false
);

const webhookUrl = "https://discord.com/api/webhooks/1485783463218118846/zV83MDC1d_JzsfMruOpQq33hQ9j65LRrDOlB8-3qkrx9mEVqHl8g5AzpIwoNe2gRb41q";
const orderForm = document.querySelector("#order-form");
const formStatus = document.querySelector("#form-status");

if (orderForm && formStatus) {
  orderForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    const formData = new FormData(orderForm);
    const name = String(formData.get("name") || "").trim();
    const orderType = String(formData.get("orderType") || "").trim();
    const budget = String(formData.get("budget") || "").trim();
    const details = String(formData.get("details") || "").trim();

    formStatus.textContent = "Sending order...";
    formStatus.classList.remove("is-error", "is-success");

    try {
      const response = await fetch(webhookUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          username: "Draco Customs Orders",
          content: "**New order inquiry**",
          embeds: [
            {
              title: "Custom Order Request",
              color: 9269247,
              fields: [
                { name: "Name", value: name || "Not provided", inline: true },
                { name: "Order Type", value: orderType || "Not provided", inline: true },
                { name: "Budget", value: budget || "Not provided", inline: true },
                { name: "Project Details", value: details || "Not provided", inline: false }
              ],
              timestamp: new Date().toISOString()
            }
          ]
        })
      });

      if (!response.ok) {
        throw new Error(`Webhook request failed with ${response.status}`);
      }

      orderForm.reset();
      formStatus.textContent = "Order sent. Check Discord for the new inquiry.";
      formStatus.classList.add("is-success");
    } catch (error) {
      formStatus.textContent = "Order failed to send. Your browser may be blocking the webhook request.";
      formStatus.classList.add("is-error");
    }
  });
}
