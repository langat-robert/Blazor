#Share data in Blazor applications
---------------------------------------------------------------------------------
Now that your app is connected to a database, it's time to add the ability to order and configure a customer's pizza.

Blazing Pizza wants you to build the ability for customers to change the size of their special pizzas. You need to store the order, and you've chosen to store the application state in a container service.

In this exercise, you'll pass data to a new order configuration component and see how to store the app's state in an OrderState scoped service.

Add a new order configuration dialog
----------------------------------------------------------------------------------
1. Stop the app if it's still running.
2. In Visual Studio Code, right-click the Shared folder and select New File.
3. Enter ConfigurePizzaDialog.razor as the filename.
4. Enter this code for the UI of the new ordering component:

    @inject HttpClient HttpClient

    <div class="dialog-container">
        <div class="dialog">
            <div class="dialog-title">
                <h2>@Pizza.Special.Name</h2>
                @Pizza.Special.Description
            </div>
            <form class="dialog-body">
                <div>
                    <label>Size:</label>
                    <input type="range" min="@Pizza.MinimumSize" max="@Pizza.MaximumSize" step="1" />
                    <span class="size-label">
                        @(Pizza.Size)" (£@(Pizza.GetFormattedTotalPrice()))
                    </span>
                </div>
            </form>

            <div class="dialog-buttons">
                <button class="btn btn-secondary mr-auto" >Cancel</button>
                <span class="mr-center">
                    Price: <span class="price">@(Pizza.GetFormattedTotalPrice())</span>
                </span>
                <button class="btn btn-success ml-auto" >Order ></button>
            </div>
        </div>
    </div>

This component is a dialog that shows the selected special pizza and allows the customer to select the pizza size.

The component needs a special pizza from the index page component to access a pizza's member values.

5. Add the Blazor @code block to allow parameters to be passed into the component:

    @code {
        [Parameter] public Pizza Pizza { get; set; }
    }


Order a pizza
-------------------------------------------------------------------------------------
When a customer selects a pizza, the dialog should allow them to change the size of their pizza. Let's enhance the index.razor control to add this interactivity.

1. In the file explorer, expand Pages, and then select Index.razor.
2. Add this code in the @code block under the List<PizzaSpecial> variable:

    Pizza configuringPizza;
    bool showingConfigureDialog;

3. Add this code to create a pizza under the OnInitializedAsync() method:

    void ShowConfigurePizzaDialog(PizzaSpecial special)
    {
        configuringPizza = new Pizza()
        {
            Special = special,
            SpecialId = special.Id,
            Size = Pizza.DefaultSize
        };

        showingConfigureDialog = true;
    }

4. Allow the webpage to call the server-side ShowConfigurePizzaDialog method by allowing customers to select a pizza's <li> tag. Replace the <li> line with this code:

    <li @onclick="@(() => ShowConfigurePizzaDialog(special))" style="background-image: url('@special.ImageUrl')">

When a customer selects a pizza, the server executes the ShowConfigurePizzaDialog method that creates a pizza with the special pizza data and sets the showingConfigureDialog variable to true.

5. The page needs a way to display the new ConfigurePizzaDialog component. Add this code above the @code block:

    @if (showingConfigureDialog)
    {
        <ConfigurePizzaDialog Pizza="configuringPizza" />
    }

The whole index.razor file should now look like this example:

    @page "/"
    @inject HttpClient HttpClient
    @inject NavigationManager NavigationManager

    <div class="main">
      <h1>Blazing Pizzas</h1>
      <ul class="pizza-cards">
        @if (specials != null)
        {
          @foreach (var special in specials)
          {
            <li @onclick="@(() => ShowConfigurePizzaDialog(special))" style="background-image: url('@special.ImageUrl')">
              <div class="pizza-info">
              <span class="title">@special.Name</span>
              @special.Description
              <span class="price">@special.GetFormattedBasePrice()</span>
              </div>
            </li>
          }
        }
      </ul>
    </div>

    @if (showingConfigureDialog)
    {
        <ConfigurePizzaDialog Pizza="configuringPizza" />
    }

    @code {
      List<PizzaSpecial> specials = new();
      Pizza configuringPizza;
      bool showingConfigureDialog;

      protected override async Task OnInitializedAsync()
      {
          specials = await HttpClient.GetFromJsonAsync<List<PizzaSpecial>>(NavigationManager.BaseUri + "specials");
      }

      void ShowConfigurePizzaDialog(PizzaSpecial special)
      {
          configuringPizza = new Pizza()
          {
              Special = special,
              SpecialId = special.Id,
              Size = Pizza.DefaultSize
          };

          showingConfigureDialog = true;
      }
    }

6. Select F5 or select Run. Then select Start Debugging.

7. Select a pizza and watch the new dialog appear.

Handle the state of an order
----------------------------------------------------------------------------------------------
At the moment, the app shows the configuration dialog but doesn't allow you to cancel or move on to ordering the pizza. To manage the state of the order, you'll add a new order state container service.

1. Stop the app if it's still running.
2. Create a new folder in the BlazingPizza folder. Name it Services.
3. Create a new file in the Services folder. Name it OrderState.cs.
4. Enter this code for the class:

    namespace BlazingPizza.Services;

    public class OrderState
    {
        public bool ShowingConfigureDialog { get; private set; }
        public Pizza ConfiguringPizza { get; private set; }
        public Order Order { get; private set; } = new Order();

        public void ShowConfigurePizzaDialog(PizzaSpecial special)
        {
            ConfiguringPizza = new Pizza()
            {
                Special = special,
                SpecialId = special.Id,
                Size = Pizza.DefaultSize,
                Toppings = new List<PizzaTopping>(),
            };

            ShowingConfigureDialog = true;
        }

        public void CancelConfigurePizzaDialog()
        {
            ConfiguringPizza = null;

            ShowingConfigureDialog = false;
        }

        public void ConfirmConfigurePizzaDialog()
        {
            Order.Pizzas.Add(ConfiguringPizza);
            ConfiguringPizza = null;

            ShowingConfigureDialog = false;
        }
    }

You'll see that there's code currently in the index.razor component that we can move into the new class. The next step is to make this service available in the app.

5. In the file explorer, select Program.cs.
6. In the part of the file with the lines that start with builder.Services., add this line:

    builder.Services.AddScoped<OrderState>();

From the previous exercise, we added our database context here. This code adds the new OrderState service. With this code in place, we can now use it in the index.razor component.

7. Add the following using directive to the top of the file to resolve the OrderState class:

    using BlazingPizza.Services;

8. In the file explorer, expand Pages, and then select Index.razor.
9. At the top of the file, under @inject NavigationManager NavigationManager, add this code:

    @using BlazingPizza.Services
    @inject OrderState OrderState

10. Remove configuringPizza, showingConfigureDialog, and ShowConfigurePizzaDialog() from the @code block. It should now look like this:

    @code {
        List<PizzaSpecial> specials = new List<PizzaSpecial>();

        protected override async Task OnInitializedAsync()
        {
            specials = await HttpClient.GetFromJsonAsync<List<PizzaSpecial>>(NavigationManager.BaseUri + "specials");
        }
    }

There are now errors where all the code references what's been deleted.

11. Change the call to ShowConfigurePizzaDialog(special)) to use the OrderState version:

    <li @onclick="@(() => OrderState.ShowConfigurePizzaDialog(special))" style="background-image: url('@special.ImageUrl')">

12. Change the reference to the Boolean showingConfigureDialog:

    @if (OrderState.ShowingConfigureDialog)

13. Change the parameter by using configuringPizza:

    <ConfigurePizzaDialog Pizza="OrderState.ConfiguringPizza" />

14. Select F5 or select Run. Then select Start Debugging.

If everything is correct, you won't see any difference. The dialog displays as it did before.

Cancel and make pizza orders
--------------------------------------------------------------------------------------------------------------------
You might have noticed in the OrderState class two methods that we haven't used yet. The CancelConfigurePizzaDialog and ConfirmConfigurePizzaDialog methods close the dialog, and add the pizza to an Order object if the customer has confirmed the order. Let's connect these methods to the configuration dialog buttons.

1. Stop the app if it's still running.
2. In the file explorer, expand Shared. Then select ConfigurePizzaDialog.razor.
3. In the @code block, add two new parameters:

    @code {
        [Parameter] public Pizza Pizza { get; set; }
        [Parameter] public EventCallback OnCancel { get; set; }
        [Parameter] public EventCallback OnConfirm { get; set; }
    }

4. The buttons can now have @onclick directives added. Change the current code for the dialog buttons to this markup:

  <div class="dialog-buttons">
      <button class="btn btn-secondary mr-auto" @onclick="OnCancel">Cancel</button>
      <span class="mr-center">
          Price: <span class="price">@(Pizza.GetFormattedTotalPrice())</span>
      </span>
      <button class="btn btn-success ml-auto" @onclick="OnConfirm">Order ></button>
  </div>

5. The last step is to pass the OrderState methods for canceling and confirming orders. In the file explorer, expand Pages. Then select Index.razor.
6. Change the code for the call to the ConfigurePizzaDialog component:

    <ConfigurePizzaDialog
      Pizza="OrderState.ConfiguringPizza"
      OnCancel="OrderState.CancelConfigurePizzaDialog"
      OnConfirm="OrderState.ConfirmConfigurePizzaDialog" />

7. Select F5 or select Run. Then select Start Debugging.

The app should now let customers cancel or add a configured pizza to an order. We have no way to show the current order or update the prices when the pizza size is changed. We'll add these features in the next exercise.
