defmodule Beacon.Loader.ComponentModuleLoader do
  require Logger

  alias Beacon.Components.Component
  alias Beacon.Loader.ModuleLoader

  def load_components(site, components) do
    component_module = Beacon.Loader.component_module_for_site(site)

    render_functions = Enum.map(components, &render_component/1)

    code_string = render(component_module, render_functions)
    Logger.debug("Loading components: \n#{code_string}")
    :ok = ModuleLoader.load(component_module, code_string)
    {:ok, code_string}
  end

  defp render(component_module, render_functions) do
    """
    defmodule #{component_module} do
      import Phoenix.LiveView.Helpers
      use Phoenix.HTML
      alias BeaconWeb.Router.Helpers, as: Routes

    #{Enum.join(render_functions, "\n")}
    end
    """
  end

  defp render_component(%Component{name: name, body: body}) do
    """
      def render(#{inspect(name)}, assigns) do
    #{~s(~H""")}
    #{body}
    #{~s(""")}
      end

    """
  end
end