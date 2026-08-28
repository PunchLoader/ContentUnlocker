using PunchAPI;
using PunchLoader;
using UnityEngine;

public sealed class ContentUnlockerPlugin : IModPlugin
{
    private static IRegistrationScope _scope;

    private static readonly string[,] HiddenColors = new string[,] {
        { "army-green-yellow", "Army Green Yellow", "ArmyGreenYellowMat" },
        { "beige-bordeaux", "Beige Bordeaux", "beigebordeauxMat" },
        { "beige-dark-orange", "Beige Dark Orange", "beigedarkorangedarkMat" },
        { "brown-orange", "Brown Orange", "brownorangeMat" },
        { "cyber-bone", "Cyber Bone", "CyberBone" },
        { "drill-ability", "Drill Ability", "DrillAbilityColor" },
        { "final-boss", "Final Boss", "FinalBossMat" },
        { "green-blue", "Green Blue", "greenblueMat" },
        { "light-green-beige", "Light Green Beige", "lightgreenbeigeMat" },
        { "orange-yellow-2", "Orange Yellow 2", "orangeyellow2Mat" },
        { "pink-brown", "Pink Brown", "pinkbrownMat" },
        { "purple-light-blue", "Purple Light Blue", "purplelightblueMat" },
        { "salmon-purple", "Salmon Purple", "salmonpurpleMat" },
        { "turquoise-beige", "Turquoise Beige", "turqoisebeigeMat" }
    };

    private static readonly string[,] HiddenParts = new string[,] {
        { "skel-valk-emperor-head", "Skel_ValkEmperorHead" },
        { "skel-valk-emperor-chest", "Skel_ValkEmperorChest" },
        { "skel-valk-emperor-arm", "Skel_ValkEmperorArm" },
        { "skel-valk-emperor-upper-arm", "Skel_ValkEmperorUpperArm" },
        { "skel-valk-emperor-hip", "Skel_ValkEmperorHip" },
        { "skel-valk-emperor-tail", "Skel_ValkEmperorTail" },
        { "skel-valk-emperor-shield", "Skel_ValkEmperorShld" }
    };

    public string GetId() { return "ContentUnlocker"; }
    public string GetName() { return "Content Unlocker"; }
    public string GetVersion() { return "0.4.0"; }

    public void OnLoad()
    {
        if (_scope != null) return;
        _scope = PunchApi.CreateScope("ContentUnlocker");
        int colors = RegisterColors();
        int parts = RegisterParts();
        Debug.Log("[ContentUnlocker] Registered " + colors +
            " hidden colors and " + parts + " hidden part variants through PunchAPI.");
    }

    public void OnUnload()
    {
        if (_scope != null) _scope.Dispose();
        _scope = null;
    }

    private static int RegisterColors()
    {
        int registered = 0;
        for (int i = 0; i < HiddenColors.GetLength(0); i++)
        {
            ColorDefinition definition = new ColorDefinition();
            definition.Id = HiddenColors[i, 0];
            definition.MaterialResourceName = HiddenColors[i, 2];
            definition.Metadata.DisplayName = HiddenColors[i, 1];
            definition.Metadata.SortOrder = i;
            definition.Metadata.HasListColor = true;
            definition.Metadata.ListColor = new Color(254f / 255f,
                254f / 255f, 0f, 1f);
            RegistrationResult result = _scope.RegisterColor(definition);
            if (ReportFailure(result, definition.Id)) registered++;
        }
        return registered;
    }

    private static int RegisterParts()
    {
        int registered = 0;
        for (int i = 0; i < HiddenParts.GetLength(0); i++)
        {
            PartDefinition definition = new PartDefinition();
            definition.Id = HiddenParts[i, 0];
            definition.PrefabResourceName = HiddenParts[i, 1];
            definition.Metadata.SortOrder = i;
            definition.Metadata.HasListColor = true;
            definition.Metadata.ListColor = new Color(254f / 255f,
                254f / 255f, 0f, 1f);
            RegistrationResult result = _scope.RegisterPart(definition);
            if (ReportFailure(result, definition.Id)) registered++;
        }
        return registered;
    }

    private static bool ReportFailure(RegistrationResult result, string id)
    {
        if (result.Success) return true;
        Debug.LogError("[ContentUnlocker] Failed to register " + id + " (" +
            result.ErrorCode + "): " + result.Message);
        return false;
    }
}
