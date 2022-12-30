defmodule JimmyWeb.Gpt2LargeLive do
  use JimmyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       text:
         "The first thing I notice is that the front of the case is made of a very thin material, which is",
       log: "",
       running: false,
       task_ref: nil
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen w-screen flex items-center justify-center antialiased">
      <div class="flex flex-col h-1/2 w-1/2">
      <h1>GPT2 - text continuation (large model)</h1>
        <form phx-submit="predict" class="m-0 flex space-x-2">
          <input
            class="block w-full p-2.5 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500"
            type="text"
            name="text"
            value={@text}
          />
          <button
            class="px-5 py-2.5 text-center mr-2 inline-flex items-center text-white bg-blue-700 font-medium rounded-lg text-sm hover:bg-blue-800 focus:ring-4 focus:ring-blue-300"
            type="submit"
            disabled={@running}
          >
            Continue this sentence
          </button>
        </form>
        <div class="mt-2 flex space-x-1.5 items-center text-gray-600 text-lg">
          <span>Sentences log:</span>
          <%= if @running do %>
            <.spinner />
          <% end %>
          <div class="text-gray-900 font-medium"><%= raw(@log) %></div>
        </div>
        <a href="/">Back to Jimmy</a>
      </div>
    </div>
    """
  end

  defp spinner(assigns) do
    ~H"""
    <svg
      class="inline mr-2 w-4 h-4 text-gray-200 animate-spin fill-blue-600"
      viewBox="0 0 100 101"
      fill="none"
      width="12"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
        fill="currentColor"
      />
      <path
        d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
        fill="currentFill"
      />
    </svg>
    """
  end

  @impl true
  def handle_event("predict", %{"text" => text}, socket) do
    task = Task.async(fn -> Nx.Serving.batched_run(Jimmy.Gpt2LargeServing, text) end)
    {:noreply, assign(socket, text: text, running: true, task_ref: task.ref)}
  end

  @impl true
  def handle_info(
        {ref, %{results: [result | _rest]}},
        %{assigns: %{task_ref: ref, log: log}} = socket
      ) do
    Process.demonitor(ref, [:flush])

    {:noreply, assign(socket, log: "#{log}<p><pre>#{result.text}</pre></p>", running: false)}
  end
end
