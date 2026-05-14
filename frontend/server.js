const express = require("express");

const app = express();


app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.set("view engine", "ejs");

// Home route
app.get("/", (req, res) => {
    res.render("index");
});

// Form submission
app.post("/submit", async (req, res) => {
    try {
        const response = await fetch("http://localhost:5000/submit", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                name: req.body.name,
                email: req.body.email
            })
        });

        const data = await response.json();
        res.send(data.message);

    } catch (error) {
        console.error(error);
        res.send("Error connecting to backend");
    }
});

app.listen(3000, () => {
    console.log("Frontend running on port 3000");
});