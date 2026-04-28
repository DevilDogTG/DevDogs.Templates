using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

namespace AvaloniaApp.ViewModels;

public partial class MainWindowViewModel : ObservableObject
{
    [ObservableProperty]
    private string _title = "AvaloniaApp";

    [ObservableProperty]
    private string _greeting = string.Empty;

    [RelayCommand]
    private void Greet() => Greeting = $"Hello from {Title}!";
}
