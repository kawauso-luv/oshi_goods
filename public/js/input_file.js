const fileInputElement = document.querySelector('input[type="file"]');
fileInputElement.addEventListener('change', (event) => {
    event.target.nextElementSibling.textContent = event.target.files[0].name;
})
