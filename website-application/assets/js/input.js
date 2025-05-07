
const targetInput = document.getElementById("target-input");
const workersInput = document.getElementById("workers-input");
const requestsInput = document.getElementById("requests-input");
const startBtn = document.getElementById("start-btn");

startBtn.addEventListener("click", async (event) => {
    event.stopPropagation();
    await fetch("http://localhost:8081/attack/start",
        {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                target: targetInput.value,
                workers: parseInt(workersInput.value),
                requests: parseInt(requestsInput.value)
            })
        }
    )
        .then(response => response.json())
        .then(data => console.log(data));
})