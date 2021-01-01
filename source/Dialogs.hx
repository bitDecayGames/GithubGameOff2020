package;

class Dialogs {

    public static inline var FakeIntro:String = "FakeIntro";
    public static inline var Intro:String = "Intro";
    public static inline var ShovelRequired:String = "ShovelRequired";
    public static inline var PlayerAlmostRanOutOfLight:String = "PlayerAlmostRanOutOfLight";
    public static inline var PlayerRanOutOfLight:String = "PlayerRanOutOfLight";
    public static inline var PlayerDied:String = "PlayerDied";
    public static inline var ShovelPurchased:String = "ShovelPurchased";
    public static inline var MatterConverterDescription:String = "MatterConverterDescription";
    public static inline var HeartJarDescription:String = "HeartJarDescription";
    public static inline var SpeedClogDescription:String = "SpeedClogDescription";
    public static inline var AxeDescription:String = "AxeDescription";
    public static inline var ShovelDescription:String = "ShovelDescription";
    public static inline var LedDescription:String = "LedDescription";
    public static inline var MatterConverterPurchased:String = "MatterConverterPurchased";
    public static inline var HeartJarPurchased:String = "HeartJarPurchased";
    public static inline var SpeedClogPurchased:String = "SpeedClogPurchased";
    public static inline var AxePurchased:String = "AxePurchased";
    public static inline var LedPurchased:String = "LedPurchased";

	public static var DialogMap:Map<String, Array<String>> = [
        FakeIntro => ["Oh look, another one came down."],
        Intro => ["Oh look, another one came down.", "If you manage to live long enough to get some money, bring it back here for some items.", "I see you have <color rgb=0xa4b50c>$5</color> on you right now.", "How about you trade me that for the <color rgb=0x0000FF>shovel</color> to get you started?", "Use the <wave>arrow keys</wave> to move and Press <wave>Z</wave> to interact with objects like my shop and ropes"],
        ShovelRequired => ["Going into the caves already? You really shouldn't go there without a <color rgb=0x0000FF>shovel</color>..."],
        PlayerAlmostRanOutOfLight => ["Wow that light was just about drained.", "You certainly are brave."],
        PlayerRanOutOfLight => ["You are lucky I found you.", "Without a light, you would have been wandering those caves for a long time.", "Obviously, rescues come with a fee...", "Don't give up"],
        PlayerDied => ["I knew you weren't tough enough...", "I wasn't <scrub height=4>actually</scrub> going to let you die down there.", "Well...<pause> <size mod=0.75>it has happened once,</size> but that was it!", "Obviously, rescues come with a fee...", "Don't give up"],
        ShovelPurchased => ["Thanks! <wave>Z</wave> is also how you swing your <color rgb=0x0000FF>shovel</color>. Go ahead, try it out.", "Also, the battery on your headlamp depletes over time. It automatically recharges up here.", "Good luck"],
        MatterConverterDescription => ["<color rgb=0x0000FF>The Matter Converter. This item will turn corpses into battery power for your light."],
        HeartJarDescription => ["<color rgb=0x0000FF>Heart Jar</color>. Double your max health."],
        SpeedClogDescription => ["<color rgb=0x0000FF>SpeedClog</color>. Slight movement speed increase."],
        AxeDescription => ["<color rgb=0x0000FF>Axe</color>. More damage."],
        ShovelDescription => ["<color rgb=0x0000FF>Shovel</color>. You are going to need this."],
        LedDescription => ["<color rgb=0x0000FF>LED Bulb</color>. Incredibly bright and efficient light bulb."],
        MatterConverterPurchased => ["Thanks! <wave>Interact with corpses</wave> in the caves to convert them into battery power.", "Every 6 corpses will give your light more charge!"],
        HeartJarPurchased => ["Thanks! Your max health has increased by 3!"],
        SpeedClogPurchased => ["Thanks! You now move a little bit faster!"],
        AxePurchased => ["Thanks! You now can deal more damage!"],
        LedPurchased => ["Thanks! You now have increased visibility and longevity on your headlamp!"],
    ];
}