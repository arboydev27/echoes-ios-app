import Foundation

struct Prompt: Identifiable {
    let id = UUID()
    let text: String
    let subtitle: String
    let category: String
    let icon: String
    var colorHex: String
    var isSaved: Bool = false
}



extension Prompt {
    static let samples: [Prompt] = [
        // Cycle 1
        Prompt(text: "What was your favorite childhood toy or game?",
               subtitle: "Think about the joy it brought and who you played with.",
               category: ThemeCategory.childhood.rawValue, icon: ThemeCategory.childhood.icon, colorHex: ThemeCategory.childhood.colorHex),
        Prompt(text: "Where did you go on your first date?",
               subtitle: "Describe the nerves and the conversation.",
               category: ThemeCategory.romance.rawValue, icon: ThemeCategory.romance.icon, colorHex: ThemeCategory.romance.colorHex),
        Prompt(text: "What is a favorite family tradition from when you were young?",
               subtitle: "How has it changed over the years?",
               category: ThemeCategory.family.rawValue, icon: ThemeCategory.family.icon, colorHex: ThemeCategory.family.colorHex),
        Prompt(text: "Describe the most beautiful place you've ever visited.",
               subtitle: "What made it so special?",
               category: ThemeCategory.travel.rawValue, icon: ThemeCategory.travel.icon, colorHex: ThemeCategory.travel.colorHex),
        Prompt(text: "What does 'home' mean to you?",
               subtitle: "Is it a place, a person, or a feeling?",
               category: ThemeCategory.home.rawValue, icon: ThemeCategory.home.icon, colorHex: ThemeCategory.home.colorHex),
        Prompt(text: "What was a difficult lesson you learned the hard way?",
               subtitle: "How did it change your perspective?",
               category: ThemeCategory.lessons.rawValue, icon: ThemeCategory.lessons.icon, colorHex: ThemeCategory.lessons.colorHex),
        Prompt(text: "What is the best piece of advice you’ve ever received?",
               subtitle: "Who gave it to you and why did it stick?",
               category: ThemeCategory.wisdom.rawValue, icon: ThemeCategory.wisdom.icon, colorHex: ThemeCategory.wisdom.colorHex),
        Prompt(text: "What was your very first job?",
               subtitle: "What did you do with your first paycheck?",
               category: ThemeCategory.work.rawValue, icon: ThemeCategory.work.icon, colorHex: ThemeCategory.work.colorHex),

        // Cycle 2
        Prompt(text: "Tell me about your childhood best friend.",
               subtitle: "What did you do together? Are you still in touch?",
               category: ThemeCategory.childhood.rawValue, icon: ThemeCategory.childhood.icon, colorHex: ThemeCategory.childhood.colorHex),
        Prompt(text: "Tell me about the most romantic thing someone has done for you.",
               subtitle: "How did it make you feel?",
               category: ThemeCategory.romance.rawValue, icon: ThemeCategory.romance.icon, colorHex: ThemeCategory.romance.colorHex),
        Prompt(text: "Describe a family member who had a big influence on you.",
               subtitle: "What did they teach you about life?",
               category: ThemeCategory.family.rawValue, icon: ThemeCategory.family.icon, colorHex: ThemeCategory.family.colorHex),
        Prompt(text: "What was your first time traveling on an airplane like?",
               subtitle: "Where were you going?",
               category: ThemeCategory.travel.rawValue, icon: ThemeCategory.travel.icon, colorHex: ThemeCategory.travel.colorHex),
        Prompt(text: "Describe the house you lived in for the longest time.",
               subtitle: "What were your favorite rooms?",
               category: ThemeCategory.home.rawValue, icon: ThemeCategory.home.icon, colorHex: ThemeCategory.home.colorHex),
        Prompt(text: "Tell me about a mentor who helped shape your career.",
               subtitle: "What was the best advice they gave you?",
               category: ThemeCategory.lessons.rawValue, icon: ThemeCategory.lessons.icon, colorHex: ThemeCategory.lessons.colorHex),
        Prompt(text: "What do you know now that you wish you knew at twenty?",
               subtitle: "What would you tell your younger self?",
               category: ThemeCategory.wisdom.rawValue, icon: ThemeCategory.wisdom.icon, colorHex: ThemeCategory.wisdom.colorHex),
        Prompt(text: "Tell me about a project you were particularly proud of.",
               subtitle: "What challenges did you overcome?",
               category: ThemeCategory.work.rawValue, icon: ThemeCategory.work.icon, colorHex: ThemeCategory.work.colorHex),

        // Cycle 3
        Prompt(text: "What was the smell of your childhood home?",
               subtitle: "Was it baking, old books, or the garden?",
               category: ThemeCategory.childhood.rawValue, icon: ThemeCategory.childhood.icon, colorHex: ThemeCategory.childhood.colorHex),
        Prompt(text: "When did you know they were 'the one'?",
               subtitle: "Was there a specific moment or a slow realization?",
               category: ThemeCategory.romance.rawValue, icon: ThemeCategory.romance.icon, colorHex: ThemeCategory.romance.colorHex),
        Prompt(text: "What was a memorable family vacation?",
               subtitle: "Where did you go and what happened?",
               category: ThemeCategory.family.rawValue, icon: ThemeCategory.family.icon, colorHex: ThemeCategory.family.colorHex),
        Prompt(text: "Tell me about a travel experience that didn't go as planned.",
               subtitle: "How did you handle the situation?",
               category: ThemeCategory.travel.rawValue, icon: ThemeCategory.travel.icon, colorHex: ThemeCategory.travel.colorHex),
        Prompt(text: "Tell me about a neighbor who made a lasting impression.",
               subtitle: "What was your relationship like?",
               category: ThemeCategory.home.rawValue, icon: ThemeCategory.home.icon, colorHex: ThemeCategory.home.colorHex),
        Prompt(text: "What is a mistake you made that ended up being a blessing?",
               subtitle: "How did things turn around?",
               category: ThemeCategory.lessons.rawValue, icon: ThemeCategory.lessons.icon, colorHex: ThemeCategory.lessons.colorHex),
        Prompt(text: "What is a motto or philosophy you live by?",
               subtitle: "How does it guide your daily choices?",
               category: ThemeCategory.wisdom.rawValue, icon: ThemeCategory.wisdom.icon, colorHex: ThemeCategory.wisdom.colorHex),
        Prompt(text: "What was the most challenging environment you ever worked in?",
               subtitle: "How did you adapt?",
               category: ThemeCategory.work.rawValue, icon: ThemeCategory.work.icon, colorHex: ThemeCategory.work.colorHex)
    ]
}
