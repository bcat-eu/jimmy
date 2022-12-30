defmodule Jimmy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      JimmyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Jimmy.PubSub},
      # Start the Endpoint (http/https)
      JimmyWeb.Endpoint,
      {Nx.Serving, serving: bertweet_serving(), name: Jimmy.BertweetServing, batch_timeout: 100},
      {Nx.Serving, serving: gpt2_serving(), name: Jimmy.Gpt2Serving, batch_timeout: 100},
      {Nx.Serving,
       serving: gpt2_large_serving(), name: Jimmy.Gpt2LargeServing, batch_timeout: 100},
      {Nx.Serving, serving: bert_ner_serving(), name: Jimmy.BertNerServing, batch_timeout: 100},
      {Nx.Serving, serving: sd_serving(), name: Jimmy.SdServing, batch_timeout: 100}
      # Start a worker by calling: Jimmy.Worker.start_link(arg)
      # {Jimmy.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jimmy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JimmyWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @spec bertweet_serving() :: Nx.Serving.t()
  defp bertweet_serving() do
    {:ok, model} = Bumblebee.load_model({:hf, "finiteautomata/bertweet-base-emotion-analysis"})

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "vinai/bertweet-base"})

    Bumblebee.Text.text_classification(model, tokenizer,
      top_k: 3,
      compile: [batch_size: 10, sequence_length: 100],
      defn_options: [compiler: EXLA]
    )
  end

  @spec gpt2_serving() :: Nx.Serving.t()
  defp gpt2_serving() do
    {:ok, model} = Bumblebee.load_model({:hf, "gpt2"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "gpt2"})

    Bumblebee.Text.generation(model, tokenizer, max_new_tokens: 12)
  end

  @spec gpt2_large_serving() :: Nx.Serving.t()
  defp gpt2_large_serving() do
    {:ok, model} = Bumblebee.load_model({:hf, "gpt2-large"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "gpt2-large"})

    Bumblebee.Text.generation(model, tokenizer, max_new_tokens: 12)
  end

  @spec bert_ner_serving() :: Nx.Serving.t()
  defp bert_ner_serving() do
    {:ok, bert} = Bumblebee.load_model({:hf, "dslim/bert-base-NER"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "bert-base-cased"})

    Bumblebee.Text.token_classification(bert, tokenizer, aggregation: :same)
  end

  @spec sd_serving() :: Nx.Serving.t()
  defp sd_serving() do
    repository_id = "CompVis/stable-diffusion-v1-4"
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai/clip-vit-large-patch14"})
    {:ok, clip} = Bumblebee.load_model({:hf, repository_id, subdir: "text_encoder"})

    {:ok, unet} =
      Bumblebee.load_model({:hf, repository_id, subdir: "unet"},
        params_filename: "diffusion_pytorch_model.bin"
      )

    {:ok, vae} =
      Bumblebee.load_model({:hf, repository_id, subdir: "vae"},
        architecture: :decoder,
        params_filename: "diffusion_pytorch_model.bin"
      )

    {:ok, scheduler} = Bumblebee.load_scheduler({:hf, repository_id, subdir: "scheduler"})

    {:ok, featurizer} =
      Bumblebee.load_featurizer({:hf, repository_id, subdir: "feature_extractor"})

    {:ok, safety_checker} = Bumblebee.load_model({:hf, repository_id, subdir: "safety_checker"})

    Bumblebee.Diffusion.StableDiffusion.text_to_image(clip, unet, vae, tokenizer, scheduler,
      num_steps: 20,
      num_images_per_prompt: 2,
      safety_checker: safety_checker,
      safety_checker_featurizer: featurizer,
      compile: [batch_size: 1, sequence_length: 60],
      defn_options: [compiler: EXLA]
    )
  end
end
