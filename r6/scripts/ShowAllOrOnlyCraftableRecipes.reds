// Copyright (c) 2023 v1ld.git@gmail.com. All Rights Reserved.
//
// Feel free to reuse under the MIT License.

@addField(CraftingLogicController)
let showAllRecipes: Bool = true;

// v1ld: this is called from CraftingMainLogicController:OpenPanel() and is where
// the recipes to display is populated
@replaceMethod(CraftingLogicController)
public func RefreshListViewContent(opt inventoryItemData: InventoryItemData) -> Void {
  // v1ld: setup button handling and callback
  this.SetupToggleCraftableRecipesButtonHints();
  this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnHandleGlobalInput");

  this.m_dataSource.Clear();
  this.m_dataSource.Reset(this.GetRecipesList());
  this.UpdateRecipePreviewPanel(this.m_selectedRecipe);
}

@replaceMethod(CraftingLogicController)
private final func GetRecipesList() -> array<ref<IScriptable>> {
  let itemRecord: wref<Item_Record>;
  let recipeData: ref<RecipeData>;
  let recipeDataList: array<ref<IScriptable>>;
  let itemRecordList: array<wref<Item_Record>> = this.m_playerCraftBook.GetCraftableItems();
  let isCraftable: Bool;
  let i: Int32 = 0;
  while i < ArraySize(itemRecordList) {
    itemRecord = itemRecordList[i];
    if IsDefined(itemRecord) {
      recipeData = this.m_craftingSystem.GetRecipeData(itemRecord);
      isCraftable = this.m_craftingSystem.CanItemBeCrafted(itemRecord);
      if isCraftable || this.showAllRecipes {
        recipeData.isNew = this.m_playerCraftBook.IsRecipeNew(recipeData.id.GetID());
        recipeData.isCraftable = isCraftable;
        recipeData.inventoryItem = this.m_inventoryManager.GetInventoryItemDataFromItemRecord(recipeData.id);
        InventoryItemData.SetQuality(recipeData.inventoryItem, UIItemsHelper.QualityEnumToName(itemRecord.Quality().Type()));
        this.m_inventoryManager.GetOrCreateInventoryItemSortData(recipeData.inventoryItem, this.m_craftingGameController.GetScriptableSystem());
        ArrayPush(recipeDataList, recipeData);
      };
    };
    i += 1;
  };
  return recipeDataList;
}

@addMethod(CraftingLogicController)
protected cb func OnHandleGlobalInput(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"world_map_menu_cycle_filter_prev") {
      this.showAllRecipes = !this.showAllRecipes;
      this.m_dataSource.Clear();
      this.m_dataSource.Reset(this.GetRecipesList());
      this.PlaySound(n"Button", n"OnPress");
    }
}

@addMethod(CraftingLogicController)
private final func SetupToggleCraftableRecipesButtonHints() -> Void {
  this.m_buttonHintsController.AddButtonHint(n"world_map_menu_cycle_filter_prev", "Toggle All/Craftable Recipes");
}
