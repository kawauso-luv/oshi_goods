const plusButton = document.querySelectorAll('.plus');
const minusButton = document.querySelectorAll('.minus');

const totalPrice = document.getElementById('totalPrice');

const updateItemCount = (e) => {
  const itemId = e.target.dataset.id;
  const action = e.target.classList.contains('plus') ? 'plus' : 'minus';
  fetch('/cart/update/quantity', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id: itemId, action: action })
  })
  .then(response => response.json())
  .then(data => {
    const idCount = document.getElementById(`${itemId}Count`);
    idCount.innerText = data.quantity;
    const idPrice = document.getElementById(`${itemId}Price`);
    idPrice.innerText = `¥${data.total_price.toLocaleString()}`;
    totalPrice.innerText = `¥${data.grand_total.toLocaleString()}`;
  })
  .catch(error => console.error('Error:', error));
};

plusButton.forEach(button => {
  button.addEventListener('click', updateItemCount);
});

minusButton.forEach(button => {
  button.addEventListener('click', updateItemCount);
});
