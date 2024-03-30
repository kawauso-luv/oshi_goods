const totalPrice = document.getElementById('totalPrice');
const itemPrices = document.querySelectorAll('.item-price');

window.addEventListener("DOMContentLoaded", () => {
  if (totalPrice) {
    totalPrice.innerText = `¥${Number(totalPrice.innerText).toLocaleString()}`;
  }
  if (itemPrices) {
    itemPrices.forEach( (e) => {
      e.innerText = `¥${Number(e.innerText).toLocaleString()}`;
    });
  }
});
