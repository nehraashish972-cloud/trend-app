const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Trend Application Running in Docker on Port 3000");
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
