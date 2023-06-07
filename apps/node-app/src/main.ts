import express from 'express';

const port = process.env.PORT ? Number(process.env.PORT) : 8080;

const app = express();

app.get('/', (req, res) => {
  res.send({ message: 'Hello SDP!!!' });
});

app.listen(port, () => {
  console.log(`[ ready ] http://localhost:${port}`);
});
