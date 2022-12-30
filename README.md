# Jimmy

Jimmy - your friendly robot.

A showcase of pretrained AI models available via [Bumblebee](https://github.com/elixir-nx/bumblebee), that are easy to integrate into a Phoenix application.

Quickstart:

- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Models

- BERTweet - text emotion recognition https://github.com/VinAIResearch/BERTweet
- BERT NER - named entity recognition https://docs.openvino.ai/latest/omz_models_model_bert_base_ner.html
- GPT2 - text continuation https://en.wikipedia.org/wiki/GPT-2, we also include an extra large model which seems to do mostly the same thing, just slower
- RoBERTa - questions answering https://github.com/facebookresearch/fairseq/blob/main/examples/roberta/README.md
- Stable Diffusion - text to image https://en.wikipedia.org/wiki/Stable_Diffusion
