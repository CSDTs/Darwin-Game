extends Popup

onready var globals = get_node("/root/Globals")
onready var main = ""

var lvl1 = [
	["[center]Charles Darwin[/center]", 'Welcome to the University of Edinburgh!'],
	["[center]Charles Darwin[/center]", 'Use the arrow keys or WASD to walk to a door, and press F to enter.'],
	["[center]Charles Darwin[/center]", 'Objective: Speak with my old professors and collect evidence about the influences that shaped my early views on slavery.']
]

var lvl2 = [
	["Charles Darwin", 'Welcome to my Uncle Josaiah\'s house!'],
	["Charles Darwin", 'Try interacting with him by using F.']
]

var lvl3 = [
	["Charles Darwin", 'Welcome to the Beagle!'],
	["Charles Darwin", 'Try interacting with the captain by using F.']
]

# Level 1 courtroom: opening exchange, then the evidence-selection UI opens.
# Long lines are split into short entries so no line needs scrolling.
var level1Complete = [
	["[center]Robert Morris[/center]", "Mr. Darwin, I've returned from Edinburgh with the evidence."],
	["[center]Charles Darwin[/center]", "Good. Edinburgh was where I first began learning from people and ideas"],
	["[center]Charles Darwin[/center]", "that challenged the assumptions of my time."],
	["[center]Prosecutor[/center]", "Let us not dress this up too nicely."],
	["[center]Prosecutor[/center]", "Charles Darwin stands accused of helping create the scientific foundation for racism."],
	["[center]Prosecutor[/center]", "His theory of evolution gave later racists a way to claim that some people were more advanced than others."],
	["[center]Prosecutor[/center]", "More civilized. More human."],
	["[center]Charles Darwin[/center]", "That is a distortion of what I believed."],
	["[center]Charles Darwin[/center]", "I opposed slavery, and I rejected the idea"],
	["[center]Charles Darwin[/center]", "that people of different races were separate kinds of human beings."],
	["[center]Prosecutor[/center]", "Opposed slavery? Then prove it."],
	["[center]Prosecutor[/center]", "Because history remembers your name alongside struggle, competition, and hierarchy."],
	["[center]Robert Morris[/center]", "That is exactly why this evidence matters."],
	["[center]Robert Morris[/center]", "Darwin's ideas did not come from racism. His early influences show a different story."],
	["[center]Time Travel Court[/center]", "Robert Morris, you have gathered evidence from Darwin's time in Edinburgh."],
	["[center]Time Travel Court[/center]", "The court will now hear your argument."],
	["[center]Time Travel Court[/center]", "But be warned: not every artifact proves the same thing."],
	["[center]Time Travel Court[/center]", "Some evidence may only show Darwin's scientific education."],
	["[center]Time Travel Court[/center]", "Some may show indirect influence."],
	["[center]Time Travel Court[/center]", "Some may speak more directly to his opposition to slavery and racism."],
	["[center]Time Travel Court[/center]", "The court is ready."],
	["[center]Time Travel Court[/center]", "Select the first piece of evidence you wish to present."]
]

# Level 1 courtroom Rocks path: the weak-evidence argument that plays when the
# player presents the rocks. Long lines are split so no entry needs scrolling.
var rocksCourtroom = [
	["[center]Robert Morris[/center]", "I present the rocks from Darwin's studies in Edinburgh."],
	["[center]Time Travel Court[/center]", "The court recognizes the evidence. Explain its relevance."],
	["[center]Robert Morris[/center]", "These rocks connect Darwin to his early education in natural history and geology."],
	["[center]Robert Morris[/center]", "They show that Darwin was learning to study nature through evidence and observation."],
	["[center]Prosecutor[/center]", "Rocks?"],
	["[center]Prosecutor[/center]", "The defense is trying to answer an accusation of racism with a pile of rocks?"],
	["[center]Prosecutor[/center]", "This proves Darwin studied science. It does not prove he opposed slavery."],
	["[center]Prosecutor[/center]", "It does not prove he rejected racism."],
	["[center]Charles Darwin[/center]", "The prosecutor is correct that the rocks alone do not prove my abolitionist beliefs."],
	["[center]Charles Darwin[/center]", "They only show part of my scientific education."],
	["[center]Robert Morris[/center]", "That is true. This evidence does not directly answer the accusation."],
	["[center]Robert Morris[/center]", "But it does show the environment where Darwin began"],
	["[center]Robert Morris[/center]", "learning to question old assumptions about nature."],
	["[center]Time Travel Court[/center]", "The court is not fully persuaded."],
	["[center]Time Travel Court[/center]", "This evidence may help explain Darwin's scientific background,"],
	["[center]Time Travel Court[/center]", "but it does very little to prove he opposed racism or slavery."],
	["[center]Time Travel Court[/center]", "A scientific education is not the same thing as abolitionist conviction."],
	["[center]Time Travel Court[/center]", "The defense has failed to present strong proof from Edinburgh."],
	["[center]Prosecutor[/center]", "Then the accusation remains standing. Rocks cannot defend a man from a charge this serious."],
	["[center]Charles Darwin[/center]", "There is stronger evidence from my time in Edinburgh."],
	["[center]Charles Darwin[/center]", "Robert, we must learn to choose more carefully."],
	["[center]Time Travel Court[/center]", "This court will allow the investigation to continue,"],
	["[center]Time Travel Court[/center]", "but the defense must bring stronger evidence in the next stage."]
]

# Level 1 courtroom Bone path: the weak-evidence argument that plays when the
# player presents the bone. Long lines are split so no entry needs scrolling.
var boneCourtroom = [
	["[center]Robert Morris[/center]", "I present the bone from Darwin's anatomy studies in Edinburgh."],
	["[center]Time Travel Court[/center]", "The court recognizes the evidence. Explain its relevance."],
	["[center]Robert Morris[/center]", "This bone shows that Darwin studied anatomy and learned about the structure of living beings."],
	["[center]Robert Morris[/center]", "It connects him to his early scientific education."],
	["[center]Prosecutor[/center]", "So the defense presents a bone."],
	["[center]Prosecutor[/center]", "That may show Darwin studied science, but it does not prove he opposed racism or slavery."],
	["[center]Charles Darwin[/center]", "That bone is part of my education, but it is not the full story of who influenced me."],
	["[center]Charles Darwin[/center]", "There is stronger evidence from my time in Edinburgh."],
	["[center]Charles Darwin[/center]", "Robert, we must learn to choose more carefully."],
	["[center]Robert Morris[/center]", "I understand. The bone gives background, but it does not directly answer the accusation."],
	["[center]Time Travel Court[/center]", "The court agrees."],
	["[center]Time Travel Court[/center]", "This evidence is relevant to Darwin's education,"],
	["[center]Time Travel Court[/center]", "but it is weak evidence for his opposition to racism."],
	["[center]Time Travel Court[/center]", "The defense has not presented strong proof from Edinburgh."],
	["[center]Prosecutor[/center]", "Then the accusation still stands. A bone cannot prove moral conviction."],
	["[center]Time Travel Court[/center]", "This court will allow the investigation to continue,"],
	["[center]Time Travel Court[/center]", "but the defense must bring stronger evidence in the next stage."]
]

# Level 1 courtroom Portrait path: the strong-evidence argument that plays when
# the player presents the portrait. Long lines are split so no entry scrolls.
var portraitCourtroom = [
	["[center]Robert Morris[/center]", "I present the portrait of Charles Darwin and John Edmonstone."],
	["[center]Time Travel Court[/center]", "The court recognizes the evidence. Explain its relevance."],
	["[center]Robert Morris[/center]", "John Edmonstone was Darwin's teacher in Edinburgh."],
	["[center]Robert Morris[/center]", "He had once been enslaved and strongly opposed slavery."],
	["[center]Robert Morris[/center]", "This portrait shows more than a student and teacher."],
	["[center]Robert Morris[/center]", "It points to one of Darwin's early abolitionist influences."],
	["[center]Prosecutor[/center]", "A portrait does not erase the accusation. How does this prove Darwin rejected racism?"],
	["[center]Robert Morris[/center]", "Edmonstone knew Darwin personally."],
	["[center]Robert Morris[/center]", "He knew Charles came from a family shaped by abolitionist beliefs."],
	["[center]Robert Morris[/center]", "Darwin's grandfather Josiah Wedgwood helped create the anti-slavery medallion"],
	["[center]Robert Morris[/center]", "asking, “Am I not a man and a brother?”"],
	["[center]Robert Morris[/center]", "His aunt Sarah supported anti-slavery societies,"],
	["[center]Robert Morris[/center]", "and Darwin heard in church that all nations were made “of one blood.”"],
	["[center]Charles Darwin[/center]", "Those ideas mattered to me. I did not see humanity as separate races of unequal worth."],
	["[center]Time Travel Court[/center]", "The court is persuaded."],
	["[center]Time Travel Court[/center]", "Unlike the bone or rocks, this evidence speaks directly to Darwin's moral influences."],
	["[center]Time Travel Court[/center]", "The portrait connects Darwin to Edmonstone, to abolitionist belief,"],
	["[center]Time Travel Court[/center]", "and to the idea that all humans belong to one family."],
	["[center]Time Travel Court[/center]", "The defense has presented strong proof from Edinburgh."],
	["[center]Charles Darwin[/center]", "Robert, this is the kind of evidence we need. My work was never meant to divide humanity."],
	["[center]Time Travel Court[/center]", "The defense wins this round."]
]

# --- Professor Jameson question-choice conversation (Level 1 only) ---
# Only Question 2 unlocks the artifact.
var jamesonNoteUnlocked = false

var jamesonOpening = [
	["[center]Robert Jameson[/center]", "My name is Robert Jameson. I teach Natural History here at Edinburgh."],
	["[center]Robert Jameson[/center]", "The Earth has a long history, if one knows how to read it. What brings you here?"],
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris. I'm an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I've come to interview the people who shaped his life and education."],
	["[center]Robert Jameson[/center]", "Charles? Curious boy, though not always awake in my lectures."],
	["[center]Robert Jameson[/center]", "Still, even a dull lecture can leave behind an idea. Ask what you like."]
]

var jamesonQ1 = [
	["[center]Robert Morris[/center]", "How does geology connect to biology?"],
	["[center]Robert Jameson[/center]", "Biology studies living things, but geology helps explain the world they live in."],
	["[center]Robert Jameson[/center]", "Rock layers show that Earth has changed over long periods of time."],
	["[center]Robert Morris[/center]", "So geology gives biology a timeline?"],
	["[center]Robert Jameson[/center]", "Exactly. If environments change over time, then organisms must be studied in that larger history."]
]

var jamesonQ2 = [
	["[center]Robert Morris[/center]", "What evidence can we find from fossils?"],
	["[center]Robert Jameson[/center]", "Fossils give us physical evidence of organisms that lived in the past."],
	["[center]Robert Jameson[/center]", "They can show body structures, where organisms lived, and how life has changed over long periods of time."],
	["[center]Robert Morris[/center]", "So fossils are not just old remains. They help scientists compare past and present life."],
	["[center]Robert Jameson[/center]", "Exactly. In biology, fossils are one line of evidence for evolution"],
	["[center]Robert Jameson[/center]", "because they show that different organisms existed at different times in Earth's history."]
]

var jamesonUnlock = [
	["[center]Robert Jameson[/center]", "You are beginning to think like a naturalist, Mr. Morris. Evidence matters more than assumption."],
	["[center]Robert Morris[/center]", "Is that something Darwin learned here?"],
	["[center]Robert Jameson[/center]", "In part, yes. Not only from lectures, but from discussion and debate."],
	["[center]Robert Morris[/center]", "What do you mean?"],
	["[center]Robert Jameson[/center]", "A note from the Plinian Society."],
	["[center]Robert Jameson[/center]", "Students used these meetings to discuss natural history, observations, and evidence."],
	["[center]Robert Jameson[/center]", "Darwin took part in that world while he was here."],
	["[center]Robert Morris[/center]", "So it does not prove his abolitionist views directly,"],
	["[center]Robert Morris[/center]", "but it shows he was learning to build arguments from evidence."],
	["[center]Robert Jameson[/center]", "Correct. In court, that may not be your strongest evidence."],
	["[center]Robert Jameson[/center]", "But it helps show the kind of thinker Darwin was becoming."]
]

# --- Professor Monro question-choice conversation (Level 1 only) ---
# Only Question 2 unlocks the artifact.
var monroBoneUnlocked = false

var monroOpening = [
	["[center]Alexander Monro[/center]", "I am Alexander Monro. I teach Anatomy here at Edinburgh."],
	["[center]Alexander Monro[/center]", "Bones, organs, muscles the parts of the body students must learn"],
	["[center]Alexander Monro[/center]", "before they are allowed anywhere near a patient. What brings you here?"],
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris. I'm an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I've come to interview the people who shaped his life and education."],
	["[center]Alexander Monro[/center]", "Darwin? Ah, yes. Bright young man, though I suspect he preferred birds and beetles to my lecture hall."],
	["[center]Alexander Monro[/center]", "Ask what you like."]
]

var monroQ1 = [
	["[center]Robert Morris[/center]", "Was Darwin studying medicine?"],
	["[center]Alexander Monro[/center]", "That was the plan, yes. His father sent him here to study medicine."],
	["[center]Robert Morris[/center]", "But he did not become a physician."],
	["[center]Alexander Monro[/center]", "No. Some students hear the call of medicine. Darwin heard the call of… practically anything else."],
	["[center]Robert Morris[/center]", "So your class was not exactly his favorite?"],
	["[center]Alexander Monro[/center]", "Let us say he survived anatomy more than he enjoyed it."]
]

var monroQ2 = [
	["[center]Robert Morris[/center]", "How could anatomy help Darwin?"],
	["[center]Alexander Monro[/center]", "Anatomy teaches a student how bodies are built."],
	["[center]Alexander Monro[/center]", "Bones, organs, muscles. They're all arranged with purpose."],
	["[center]Robert Morris[/center]", "So even if Darwin disliked medicine, studying bodies could still help him understand animals."],
	["[center]Alexander Monro[/center]", "Exactly. A naturalist must compare living things. Anatomy teaches the eye what to notice."],
	["[center]Robert Morris[/center]", "So it helped him observe and compare life more carefully."],
	["[center]Alexander Monro[/center]", "Precisely. Darwin may not have loved my lectures, but anatomy still taught him what to look for."]
]

var monroUnlock = [
	["[center]Alexander Monro[/center]", "Here, perhaps this will make the lesson less abstract."],
	["[center]Robert Morris[/center]", "What is it?"],
	["[center]Alexander Monro[/center]", "A bone."],
	["[center]Robert Morris[/center]", "A bone?"],
	["[center]Alexander Monro[/center]", "Yes. Simple, sturdy, and less likely to fall asleep during lecture than Mr. Darwin."],
	["[center]Robert Morris[/center]", "I suppose it does represent anatomy."],
	["[center]Alexander Monro[/center]", "Indeed. It will not explain everything about Darwin,"],
	["[center]Alexander Monro[/center]", "but it reminds us that his science began with observing living bodies closely."]
]

# --- Professor Edmonstone question-choice conversation (Level 1 only) ---
# Unlike Monro/Jameson, only Question 3 unlocks the artifact.
var edmonstonePortraitUnlocked = false

var edmonstoneOpening = [
	["[center]John Edmonstone[/center]", "My name is John Edmonstone. I teach taxidermy here in Edinburgh. What brings you here?"],
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris. I'm an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I've come to interview people about his life."],
	["[center]John Edmonstone[/center]", "Charles? Yes, I remember him. Curious, thoughtful, and always asking questions. Ask what you like."]
]

var edmonstoneQ1 = [
	["[center]Robert Morris[/center]", "What did you teach Darwin?"],
	["[center]John Edmonstone[/center]", "I taught him taxidermy — how to preserve birds and prepare specimens for study."],
	["[center]Robert Morris[/center]", "So your lessons helped him as a naturalist?"],
	["[center]John Edmonstone[/center]", "Yes. A naturalist must know how to observe carefully."],
	["[center]John Edmonstone[/center]", "The small differences in beaks, wings, feathers. Those details matter"]
]

var edmonstoneQ2 = [
	["[center]Robert Morris[/center]", "Did Darwin come from an abolitionist family?"],
	["[center]John Edmonstone[/center]", "Yes. Charles told me about his grandfather Josiah, who created an anti-slavery medallion."],
	["[center]Robert Morris[/center]", "His grandfather was against slavery?"],
	["[center]John Edmonstone[/center]", "Strongly. And Charles also spoke of his aunt Sarah, who made large donations to the anti-slavery society."],
	["[center]Robert Morris[/center]", "So Darwin grew up around people who opposed slavery."],
	["[center]John Edmonstone[/center]", "He did. Even at Charles' church, they would say,"],
	["[center]John Edmonstone[/center]", "“the universal father has made of one blood all nations.”"]
]

var edmonstoneQ3 = [
	["[center]Robert Morris[/center]", "Did Darwin ever speak about slavery or abolition with you?"],
	["[center]John Edmonstone[/center]", "Yes. Charles told me about his family and the beliefs that shaped him."],
	["[center]John Edmonstone[/center]", "His grandfather, Josiah Wedgwood, helped create a famous anti-slavery medallion."],
	["[center]John Edmonstone[/center]", "It asked, “Am I not a man and a brother?”"],
	["[center]John Edmonstone[/center]", "Charles also spoke of his aunt Sarah, who gave large donations to anti-slavery societies."],
	["[center]Robert Morris[/center]", "So Darwin was surrounded by abolitionist ideas before he became famous?"],
	["[center]John Edmonstone[/center]", "Very much so. Even in church, Charles heard that the Universal Father"],
	["[center]John Edmonstone[/center]", "“hath made of one blood all nations.”"],
	["[center]John Edmonstone[/center]", "That meant all people shared one human family, no matter their color or nation."],
	["[center]John Edmonstone[/center]", "As someone formerly enslaved, it gave me joy to see that Charles was a strong abolitionist."],
	["[center]Robert Morris[/center]", "That sounds important. Is there evidence of your connection to him?"],
	["[center]John Edmonstone[/center]", "Yes. I had a portrait of the two of us commissioned."],
	["[center]John Edmonstone[/center]", "It shows more than a student and teacher."],
	["[center]John Edmonstone[/center]", "It shows one of the influences that helped shape Charles against slavery."],
	["[center]John Edmonstone[/center]", "You will find the portrait in that box."],
	["[center]New Evidence[/center]", "New evidence unlocked: Portrait of Darwin and John Edmonstone."]
]

var edmonstoneUnlock = [
	["[center]John Edmonstone[/center]", "That is why I had a portrait of the two of us commissioned."],
	["[center]Robert Morris[/center]", "Where is it?"],
	["[center]John Edmonstone[/center]", "You will find it in that box."],
	["[center]Robert Morris[/center]", "Then I should take a look."]
]

var edmonstoneAfter = [
	["[center]John Edmonstone[/center]", "I have already given you the portrait. You will find it in that box."]
]



var monro = [
	["[center]Alexander Monro[/center]", "Hello there. My name is Alexander Monro. I teach Anatomy."],
	["[center]Alexander Monro[/center]", "What brings you here?"],	
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris."],
	["[center]Robert Morris[/center]", "I’m an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I’ve come to do an interview about his life."],
	["[center]Alexander Monro[/center]","I once overheard young Charles say that he thinks my lectures are dull."],
	["[center]Alexander Monro[/center]","I suppose that explains his poor exam grades."],
	["[center]Alexander Monro[/center]"," Over in that box you will find one of the bones I was lecturing on."],
	["[center]Alexander Monro[/center]", "You can bring that back to him as a reminder that I have a bone to pick with him."]
]

var edmonstone = [
	["[center]John Edmonstone[/center]", "Hello there. My name is John Edmonstone. I teach Taxidermy."],
	["[center]John Edmonstone[/center]", "What brings you here?"],	
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris."],
	["[center]Robert Morris[/center]", "I’m an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I’ve come to do an interview about his life."],
	["[center]John Edmonstone[/center]","Charles told me about his grandfather Josiah, who created an anti-slavery medallion."],
	["[center]John Edmonstone[/center]","And his Aunt Sarah, who made huge donations to the anti-slavery society."],
	["[center]John Edmonstone[/center]"," At Charles’ church, they would say…"],
	["[center]John Edmonstone[/center]", "The universal father has made of one blood all nations."],
	["[center]John Edmonstone[/center]"," As someone formally enslaved, it was a joy to find that Charles Darwin was a strong abolitionist."],
	["[center]John Edmonstone[/center]"," That is why I had a portrait of the two of us commissioned. "],
	["[center]John Edmonstone[/center]"," You will find it in that box over there.."],
]

var jameson = [
	["[center]Robert Jameson[/center]", "Hello there. My name is Robert Jameson. I teach Geology."],
	["[center]Robert Jameson[/center]", "What brings you here?"],	
	["[center]Robert Morris[/center]", "Hello. My name is Robert Morris."],
	["[center]Robert Morris[/center]", "I’m an acquaintance of Charles Darwin."],
	["[center]Robert Morris[/center]", "I’ve come to do an interview about his life."],
	["[center]Robert Jameson[/center]","Charles sometimes falls asleep in my class."],
	["[center]Robert Jameson[/center]","Perhaps you can get him to pay more attention. "],
	["[center]Robert Jameson[/center]"," You are welcome to take one of my rocks as a reminder if you like."],
	["[center]Robert Jameson[/center]"," Check in that box over there."],
]

var failBone = [
	["[center]Robert Morris[/center]", "Well Mr. Darwin, I hope this is the evidence we need."],
	["[center]Robert Morris[/center]", "I think it is a bone…"],	
	["[center]Charles Darwin[/center]", "That has nothing to do with my abolitionist background."],
	["[center]Charles Darwin[/center]", "You did all that time travel for nothing."],
	["[center]Robert Morris[/center]", "Sorry about that. Let me try again."],	
]
var failRocks = [
	["[center]Robert Morris[/center]", "Well Mr. Darwin, I hope this is the evidence we need."],
	["[center]Robert Morris[/center]", "I think it is a pile of rocks..."],	
	["[center]Charles Darwin[/center]", "That has nothing to do with my abolitionist background."],
	["[center]Charles Darwin[/center]", "You did all that time travel for nothing."],
	["[center]Robert Morris[/center]", "Sorry about that. Let me try again."],	
]
var successPortrait = [
	["[center]Robert Morris[/center]", "Well Mr. Darwin, I hope this is the evidence we need."],
	["[center]Robert Morris[/center]", "It is a picture of you and John Edmonstone."],	
	["[center]Charles Darwin[/center]", "That's it! He was well known for his opposition to slavery..."],
	["[center]Charles Darwin[/center]", "having once been enslaved himself."],
	["[center]Charles Darwin[/center]", "And he was my favorite teacher."],
	["[center]Charles Darwin[/center]", "Now onto the second bit of evidence."],
	["[center]Charles Darwin[/center]", "My Uncle Josiah could be of help to you."],
	["[center]Charles Darwin[/center]", "Backin 1831, I received an invitation to go aboard The Beagle."],
	["[center]Charles Darwin[/center]", "My father said no!"],
	["[center]Charles Darwin[/center]", "So I went to Uncle Josiah to get help convincing my dad."],
	["[center]Charles Darwin[/center]", "If anyone could vouch for me, it would be him."],
	["[center]Robert Morris[/center]", "Wish me luck!"],	
]

var monroAfter = [
	["[center]Alexander Monro[/center]", "I'm sorry Mr. Morris, but I have nothing left to offer."],
	["[center]Alexander Monro[/center]", "Perhaps the Taxidermy or Geology professors might have more to offer..."],	
]

var jamesonAfter = [
	["[center]Robert Jameson[/center]", "I'm sorry Mr. Morris, but I have nothing left to offer."],
	["[center]Robert Jameson[/center]", "Perhaps the Taxidermy or Anatomy professors might have more to offer..."],	
]

var uncleAfter = [
	["[center]Robert Jameson[/center]", "I'm sorry Mr. Morris, but I have nothing left to offer."],
	["[center]Robert Jameson[/center]", "Perhaps the Taxidermy or Anatomy professors might have more to offer..."],	
]



var uncle = [
	["Josaiah Wedgewood", "Hello there. My name is Josaiah Wedgewood."],
	["Josaiah Wedgewood", "What seems to bring you to my home on this fine day?"],	
	["Robert Morris", "Hello. My name is Robert Morris."],
	["Robert Morris", "I’m an acquaintance of your nephew Charles Darwin."],
	["Robert Morris", "He said he missed home, and asked me to bring back some reminder of his life."],
	["Josaiah Wedgewood","Well you are welcome to take anything in the room."],
	["Josaiah Wedgewood","I don’t have much use for this stuff any more."],
]

var failTeapot = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a teapot..."],	
	["Charles Darwin", "That has nothing to do with my abolitionist background."],
	["Charles Darwin", "You did all that time travel for nothing."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var failPlate = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a plate..."],	
	["Charles Darwin", "That has nothing to do with my abolitionist background."],
	["Charles Darwin", "You did all that time travel for nothing."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var successMedallion = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is some sort of medallion."],	
	["Charles Darwin", "That's it!"],
	["Charles Darwin", "The anti-slavery medallion from my great grandfather, (also named Josiah)."],
	["Charles Darwin", "Clear evidence if there ever was one."],
	["Robert Morris",  "Where else can I find evidence to help you prove your abolitionist background?"],
	["Charles Darwin", "The last place that comes to my mind is the Beagle."],
	["Charles Darwin", "Would you mind making a stop there and chat with Captain Fitzroy?"],
	["Charles Darwin", "He definitely will prove a lot of useful information for you."],
	["Robert Morris", "Sure! It\'s time for me to go. I\'ll be back shortly."],	
]

var failedAttempt = [
	["Josaiah Wedgewood", "Hello again, Mr. Morris. Not what you were looking for?"],
	["Josaiah Wedgewood", "I'm sure I have a few more items laying around."],	
	["Josaiah Wedgewood", "Why don\'t you try something else?"],	
]


var failedAttempt2 = [
	["Captain Fitzroy", "Hello again, Mr. Morris. Not what you were looking for?"],
	["Captain Fitzroy", "I'm sure I have a few more items laying around the boat."],	
	["Captain Fitzroy", "Why don\'t you try another journal?"],	
]

var captain = [
	["Robert Morris", " Hello! I believe you are Captain Fitzroy?"],
	["Captain Fitzroy", "Yes, I am. What brings you here?"],	
	["Robert Morris", "I’m a friend of Charles Darwin, and I'm here to hear his life story."],
	["Robert Morris", "What happened on the Beagle?"],
	["Captain Fitzroy","We argued often."],
	["Captain Fitzroy","He claimed that slave owners invented the myth that black people were an “other kind” of person, not true humans."],
	["Captain Fitzroy","Darwin’s view was the opposite: he said we are just one species."],
	["Captain Fitzroy","The humans-who adapted to different environments with skin color, height, and other trivial changes."],
	["Captain Fitzroy","You can find 3 of his notebooks in the boxes here."],
	["Captain Fitzroy","They cover many of his scientific theories and views."],
	["Robert Morris", "Thank you, Captain! It will be super helpful."],
]

var page1 = [
	["Robert Morris", "Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a journal entry about mollusca and vertebrate..."],	
	["Charles Darwin", "Unfortunately, it has nothing to do with my abolitionist background."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var page2 = [
	["Robert Morris", "Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "I think it is a journal entry about tapirs..."],	
	["Charles Darwin", "Unfortunately, it has nothing to do with my abolitionist background."],
	["Robert Morris", "Sorry about that. Let me try again."],	
]
var page3 = [
	["Robert Morris", "Well Mr. Darwin, I hope this is the evidence we need."],
	["Robert Morris", "It’s the place in your journal where you show how slave owners were using a myth about Africans."],	
	["Charles Darwin", "That's it!"],
	["Charles Darwin", "That’s the journal page where I wrote about how slave owners justify their crimes."],
	["Charles Darwin", " They claim that white and black people are separate species."],
	["Robert Morris",  "But clearly all humans were once black, and Europeans adapted to the lack of sun with white skin."],
	["Charles Darwin", "That’s how the evolution concept first came to me."],
	["Robert Morris", "Now, I believe that I have enough evidence. We shall go back to the judge."],
	["Robert Morris", "Your honor, I bring back some photographic evidence that would prove Darwin is not the founder of racism."],
	["Robert Morris", "His theory of evolution actually comes from his abolitionist commitments."],	
	["Time Travel Court","Please, elaborate on this."],	
	["Robert Morris", "Darwin’s family has been devoted to the anti-slavery cause, as you can see in this medalion."],	
	["Robert Morris", "Darwin himself is no less committed."],	
	["Robert Morris", "His journal mentioned John Edmondstone, a Black teacher at the University of Edinburgh..."],	
	["Robert Morris", "Proof that the black mind is equal to that of whites"],	
	["Robert Morris", "And most telling, he took the abolitionist idea--“we are all brothers and sisters”--as a model for human change in skin color."],	
	["Robert Morris", "Which then gave him a model for all animal change."],	
	["Robert Morris", "The very idea of evolution comes from Darwin’s strong anti-racist view."],	
	["Time Travel Court","This is all the evidence I need. Mr. Morris, we truly appreciate your hard work to help us find out the truth."],	
	["Time Travel Court"," Mr. Darwin, we are sorry for the misunderstanding."],	
	["Time Travel Court"," From now on, everyone shall know of your research as science and social justice working hand in hand."],	
	["Charles Darwin", " Mr. Morris, thank you for your effort!"],	
]
var dialog_index = 0
var finished = false


func launch_conversation(name):
	init_conversation(name)
	launch_popup()
	load_dialog()

func launch_popup():
	globals.canMove = false
	self.visible = true

func init_conversation(conversation):
	if conversation == "Monro":
		main = monroOpening
	elif conversation == "MonroQ1":
		main = monroQ1
	elif conversation == "MonroQ2":
		main = monroQ2
	elif conversation == "MonroUnlock":
		main = monroUnlock
	elif conversation == "MonroAfter":
		main = monroAfter
	elif conversation == "JamesonAfter":
		main = jamesonAfter
	elif conversation == "Edmonstone":
		main = edmonstoneOpening
	elif conversation == "EdmonstoneQ1":
		main = edmonstoneQ1
	elif conversation == "EdmonstoneQ2":
		main = edmonstoneQ2
	elif conversation == "EdmonstoneQ3":
		main = edmonstoneQ3
	elif conversation == "EdmonstoneUnlock":
		main = edmonstoneUnlock
	elif conversation == "EdmonstoneAfter":
		main = edmonstoneAfter
	elif conversation == "Jameson":
		main = jamesonOpening
	elif conversation == "JamesonQ1":
		main = jamesonQ1
	elif conversation == "JamesonQ2":
		main = jamesonQ2
	elif conversation == "JamesonUnlock":
		main = jamesonUnlock
	elif conversation =="Bone":
		main = failBone
	elif conversation =="Rocks":
		main = failRocks
	elif conversation =="Portrait":
		main = successPortrait
	elif conversation == "Uncle":
		main = uncle
	elif conversation =="Teapot":
		main = failTeapot
	elif conversation =="Plate":
		main = failPlate
	elif conversation =="Medallion":
		main = successMedallion
	elif conversation =="UncleAfter":
		main = failedAttempt
	elif conversation == "Captain":
		main = captain
	elif conversation =="CaptainAfter":
		main = failedAttempt2
	elif conversation =="Page1":
		main = page1
	elif conversation =="Page2":
		main = page2
	elif conversation =="Page3":
		main = page3
	elif conversation == "Level1Complete":
		main = level1Complete
	elif conversation == "RocksCourtroom":
		main = rocksCourtroom
	elif conversation == "BoneCourtroom":
		main = boneCourtroom
	elif conversation == "PortraitCourtroom":
		main = portraitCourtroom

	# When a courtroom conversation begins, lay out and reset the portraits so
	# they can fade in cleanly on the first line.
	if _is_courtroom_convo():
		_prepare_courtroom_layout()

	dialog_index = 0
	finished = false
	
func _ready():
	if get_tree().get_current_scene().get_name() == "Level1":
		main = lvl1
		_connect_jameson_menu()
		_connect_monro_menu()
		_connect_edmonstone_menu()
	elif get_tree().get_current_scene().get_name() == "Level2":
		main = lvl2
	elif get_tree().get_current_scene().get_name() == "Level3":
		main = lvl3
	self.visible = true
	globals.canMove = false
	load_dialog()

# Hooks up Jameson's question buttons (Level 1 only). Safe no-op elsewhere.
func _connect_jameson_menu():
	var menu = get_node_or_null("/root/Level1/JamesonMenu/QuestionMenu")
	if menu != null:
		menu.visible = false
		menu.get_node("Button_Q1").connect("pressed", self, "_on_jameson_question", [1])
		menu.get_node("Button_Q2").connect("pressed", self, "_on_jameson_question", [2])
		_style_question_menu(menu, ["Button_Q1", "Button_Q2"])

# Hooks up Monro's question buttons (Level 1 only). Safe no-op elsewhere.
func _connect_monro_menu():
	var menu = get_node_or_null("/root/Level1/MonroMenu/QuestionMenu")
	if menu != null:
		menu.visible = false
		menu.get_node("Button_Q1").connect("pressed", self, "_on_monro_question", [1])
		menu.get_node("Button_Q2").connect("pressed", self, "_on_monro_question", [2])
		_style_question_menu(menu, ["Button_Q1", "Button_Q2"])

# Hooks up Edmonstone's question buttons (Level 1 only). Safe no-op elsewhere.
func _connect_edmonstone_menu():
	var menu = get_node_or_null("/root/Level1/EdmonstoneMenu/QuestionMenu")
	if menu != null:
		menu.visible = false
		menu.get_node("Button_Q1").connect("pressed", self, "_on_edmonstone_question", [1])
		menu.get_node("Button_Q2").connect("pressed", self, "_on_edmonstone_question", [2])
		menu.get_node("Button_Q3").connect("pressed", self, "_on_edmonstone_question", [3])
		_style_question_menu(menu, ["Button_Q1", "Button_Q2", "Button_Q3"])

# --- Shared parchment styling for the Level 1 professor question menus ---
# One implementation for all three professors: a cream/parchment card with warm
# brown borders (matching the objective/dialogue/Case File look), placed on the
# right so the professor portrait on the left stays clear.

const MENU_TEXT = Color(0.30, 0.20, 0.10)
const MENU_TEXT_DARK = Color(0.16, 0.10, 0.04)

func _menu_font(font_size):
	var f = DynamicFont.new()
	f.font_data = load("res://Assets/Fonts/Raleway-Bold.ttf")
	f.size = font_size
	return f

func _menu_panel_style():
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.949019, 0.886274, 0.745098, 0.98)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.541176, 0.388235, 0.227451)
	sb.set_corner_radius_all(14)
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 6
	return sb

func _menu_button_style(bg):
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(2)
	sb.border_color = Color(0.541176, 0.388235, 0.227451)
	sb.set_corner_radius_all(9)
	return sb

# Lays out and skins one professor question menu. Node names (QuestionMenu /
# Prompt / Button_Qn) and their signal wiring are untouched, so all question
# logic and artifact unlocks keep working.
func _style_question_menu(menu, button_names):
	var count = button_names.size()
	var panel_w = 710
	var pad = 28
	var heading_h = 52
	var gap_after_heading = 22
	var button_h = 64
	var button_gap = 20
	var top_pad = 30
	var bottom_pad = 30
	var panel_h = top_pad + heading_h + gap_after_heading + count * button_h + (count - 1) * button_gap + bottom_pad
	# Centered in the full 1280x720 viewport (the professor portrait is hidden
	# while the menu is up, so nothing needs to be cleared on the left).
	var panel_x = (1280 - panel_w) / 2
	var panel_y = (720 - panel_h) / 2

	menu.anchor_left = 0.0
	menu.anchor_top = 0.0
	menu.anchor_right = 0.0
	menu.anchor_bottom = 0.0
	menu.margin_left = panel_x
	menu.margin_top = panel_y
	menu.margin_right = panel_x + panel_w
	menu.margin_bottom = panel_y + panel_h
	menu.add_stylebox_override("panel", _menu_panel_style())

	var prompt = menu.get_node_or_null("Prompt")
	if prompt != null:
		prompt.margin_left = pad
		prompt.margin_top = top_pad
		prompt.margin_right = panel_w - pad
		prompt.margin_bottom = top_pad + heading_h
		prompt.add_font_override("font", _menu_font(27))
		prompt.add_color_override("font_color", MENU_TEXT)
		prompt.align = 1
		prompt.valign = 1

	var by = top_pad + heading_h + gap_after_heading
	for bname in button_names:
		var btn = menu.get_node_or_null(bname)
		if btn != null:
			btn.margin_left = pad
			btn.margin_right = panel_w - pad
			btn.margin_top = by
			btn.margin_bottom = by + button_h
			btn.add_font_override("font", _menu_font(22))
			btn.add_color_override("font_color", MENU_TEXT)
			btn.add_color_override("font_color_hover", MENU_TEXT_DARK)
			btn.add_color_override("font_color_pressed", MENU_TEXT_DARK)
			btn.add_color_override("font_color_focus", MENU_TEXT)
			btn.add_stylebox_override("normal", _menu_button_style(Color(0.929411, 0.870588, 0.717647, 1)))
			btn.add_stylebox_override("hover", _menu_button_style(Color(0.980392, 0.937254, 0.815686, 1)))
			btn.add_stylebox_override("pressed", _menu_button_style(Color(0.858823, 0.776470, 0.6, 1)))
			btn.add_stylebox_override("focus", _menu_button_style(Color(0.980392, 0.937254, 0.815686, 1)))
		by += button_h + button_gap


func _process(delta):
	$"next-indicator".visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if self.visible == true:
			load_dialog()

func load_dialog():
	if dialog_index < main.size():
		finished = false
		$"dialog-text".bbcode_text = main[dialog_index][1]
		$"name-label".bbcode_text = main[dialog_index][0]
		if _is_courtroom_convo():
			_update_courtroom_speaker(main[dialog_index][0], main[dialog_index][1])
		$"dialog-text".percent_visible = 0
		$Tween.interpolate_property($"dialog-text", "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		self.visible = false
		globals.canMove = true

		# Professor Jameson question-choice flow (Level 1 only)
		# Only Question 2 unlocks the note; Question 1 just returns to the menu.
		if main == jamesonOpening:
			_show_jameson_menu()
		elif main == jamesonQ1:
			_show_jameson_menu()
		elif main == jamesonQ2:
			# Deferred to avoid re-entering load_dialog from inside itself.
			call_deferred("_start_jameson_dialogue", "JamesonUnlock")
		elif main == jamesonUnlock:
			if not jamesonNoteUnlocked:
				jamesonNoteUnlocked = true
				get_node("/root/Level1/Rocks").visible = true
				get_node("/root/Level1/Rocks/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Jameson/CanvasLayer/Control").visible = false

		# Professor Monro question-choice flow (Level 1 only)
		# Only Question 2 unlocks the bone; Question 1 just returns to the menu.
		if main == monroOpening:
			_show_monro_menu()
		elif main == monroQ1:
			_show_monro_menu()
		elif main == monroQ2:
			# Deferred to avoid re-entering load_dialog from inside itself.
			call_deferred("_start_monro_dialogue", "MonroUnlock")
		elif main == monroUnlock:
			if not monroBoneUnlocked:
				monroBoneUnlocked = true
				get_node("/root/Level1/Bone").visible = true
				get_node("/root/Level1/Bone/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Monro/CanvasLayer/Control").visible = false

		# Professor Edmonstone question-choice flow (Level 1 only)
		# Only Question 3 unlocks the portrait; Q1/Q2 just return to the menu.
		if main == edmonstoneOpening:
			_show_edmonstone_menu()
		elif main == edmonstoneQ1 or main == edmonstoneQ2:
			_show_edmonstone_menu()
		elif main == edmonstoneQ3:
			# The Q3 dialogue itself ends with the box reveal, so unlock the
			# portrait directly (existing unlock behavior) instead of chaining.
			if not edmonstonePortraitUnlocked:
				edmonstonePortraitUnlocked = true
				get_node("/root/Level1/Portrait").visible = true
				get_node("/root/Level1/Portrait/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Edmonstone/CanvasLayer/Control").visible = false
		elif main == edmonstoneUnlock:
			if not edmonstonePortraitUnlocked:
				edmonstonePortraitUnlocked = true
				get_node("/root/Level1/Portrait").visible = true
				get_node("/root/Level1/Portrait/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Edmonstone/CanvasLayer/Control").visible = false
		elif main == edmonstoneAfter:
			get_node("/root/Level1/Edmonstone/CanvasLayer/Control").visible = false

		if main == monro:
			get_node("/root/Level1/Bone").visible = true
			get_node("/root/Level1/Bone/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Monro/CanvasLayer/Control").visible = false
		elif main == jameson:
			get_node("/root/Level1/Rocks").visible = true
			get_node("/root/Level1/Rocks/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Jameson/CanvasLayer/Control").visible = false
		elif main == edmonstone:
			get_node("/root/Level1/Portrait").visible = true
			get_node("/root/Level1/Portrait/CollisionShape2D").one_way_collision = false
			get_node("/root/Level1/Edmonstone/CanvasLayer/Control").visible = false
		elif main == monroAfter:
			get_node("/root/Level1/Monro/CanvasLayer/Control").visible = false
		elif main == jamesonAfter:
			get_node("/root/Level1/Jameson/CanvasLayer/Control").visible = false
		elif main == failedAttempt:
			get_node("/root/Level2/Uncle/CanvasLayer/Control").visible = false
		elif main == failedAttempt2:
			get_node("/root/Level3/Captain/CanvasLayer/Control").visible = false
		elif main == failRocks:
			get_node("/root/Level1/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level1/Rocks").queue_free()
		elif main == failBone:
			get_node("/root/Level1/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level1/Bone").queue_free()
		elif main == successPortrait:
			get_node("/root/Level1/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level1/Portrait").queue_free()
			get_node("/root/Level1/CanvasLayer/NextLevel").visible = true
		elif main == level1Complete:
			# Keep the courtroom backdrop and open evidence selection (no auto-advance).
			var evidence_select = get_node_or_null("/root/Level1/EvidenceSelect")
			if evidence_select != null:
				evidence_select.open()
		elif main == rocksCourtroom or main == boneCourtroom or main == portraitCourtroom:
			# Courtroom argument finished: show the result screen (weak for
			# Rocks/Bone, strong for Portrait — EvidenceSelect decides from the
			# stored selection).
			var evidence_select_r = get_node_or_null("/root/Level1/EvidenceSelect")
			if evidence_select_r != null:
				evidence_select_r.show_result()
		elif main == uncle:
			get_node("/root/Level2/Teapot").visible = true
			get_node("/root/Level2/Teapot/CollisionShape2D").one_way_collision = false
			get_node("/root/Level2/Plate").visible = true
			get_node("/root/Level2/Plate/CollisionShape2D").one_way_collision = false
			get_node("/root/Level2/Medallion").visible = true
			get_node("/root/Level2/Medallion/CollisionShape2D").one_way_collision = false
			get_node("/root/Level2/Uncle/CanvasLayer/Control").visible = false
		elif main == failTeapot:
			get_node("/root/Level2/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level2/Teapot").queue_free()
		elif main == failPlate:
			get_node("/root/Level2/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level2/Plate").queue_free()
		elif main == successMedallion:
			get_node("/root/Level2/CanvasLayer/Courtroom").visible = false
			var med2 = get_node_or_null("/root/Level2/Medallion")
			if med2 != null:
				med2.queue_free()
			get_node("/root/Level2/CanvasLayer/NextLevel").visible = true
		elif main == captain:
			get_node("/root/Level3/Page1").visible = true
			get_node("/root/Level3/Page1/CollisionShape2D").one_way_collision = false
			get_node("/root/Level3/Page2").visible = true
			get_node("/root/Level3/Page2/CollisionShape2D").one_way_collision = false
			get_node("/root/Level3/Page3").visible = true
			get_node("/root/Level3/Page3/CollisionShape2D").one_way_collision = false
			get_node("/root/Level3/Captain/CanvasLayer/Control").visible = false
		elif main == page1:
			get_node("/root/Level3/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level3/Page1").queue_free()
		elif main == page2:
			get_node("/root/Level3/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level3/Page2").queue_free()
		elif main == page3:
			get_node("/root/Level3/CanvasLayer/Courtroom").visible = false
			get_node("/root/Level3/Page3").queue_free()
			get_node("/root/Level3/CanvasLayer/NextLevel").visible = true
			
	dialog_index += 1

func _on_Tween_tween_completed(object, key):
	finished = true

# --- Jameson question menu helpers (Level 1 only) ---

# Toggles a professor's on-screen portrait (their NPC CanvasLayer/Control, which
# holds the professor + lawyer sprites). Hidden while the question menu is up.
func _set_professor_portrait(prof, is_visible):
	var ctrl = get_node_or_null("/root/Level1/" + prof + "/CanvasLayer/Control")
	if ctrl != null:
		ctrl.visible = is_visible

# Shows the question menu, or, once both questions have been asked, moves on to
# the artifact unlock dialogue instead.
func _show_jameson_menu():
	var menu = get_node_or_null("/root/Level1/JamesonMenu/QuestionMenu")
	if menu == null:
		return
	if jamesonNoteUnlocked:
		menu.visible = false
		# Note already given: play a short repeat line instead of the menu.
		call_deferred("_start_jameson_dialogue", "JamesonAfter")
	else:
		globals.canMove = false
		# Hide the portrait so only the centered question panel is shown.
		_set_professor_portrait("Jameson", false)
		menu.visible = true

# Button callback: plays the chosen question's dialogue.
func _on_jameson_question(question):
	var menu = get_node_or_null("/root/Level1/JamesonMenu/QuestionMenu")
	if menu != null:
		menu.visible = false
	if question == 1:
		_start_jameson_dialogue("JamesonQ1")
	elif question == 2:
		_start_jameson_dialogue("JamesonQ2")

# Opens the popup on a Jameson sub-conversation and shows its first line.
func _start_jameson_dialogue(conversation):
	# Restore the portrait for dialogue (it was hidden during the menu).
	_set_professor_portrait("Jameson", true)
	init_conversation(conversation)
	launch_popup()
	load_dialog()

# --- Monro question menu helpers (Level 1 only) ---

# Shows the question menu, or, once both questions have been asked, moves on to
# the artifact unlock dialogue instead.
func _show_monro_menu():
	var menu = get_node_or_null("/root/Level1/MonroMenu/QuestionMenu")
	if menu == null:
		return
	if monroBoneUnlocked:
		menu.visible = false
		# Bone already given: play a short repeat line instead of the menu.
		call_deferred("_start_monro_dialogue", "MonroAfter")
	else:
		globals.canMove = false
		# Hide the portrait so only the centered question panel is shown.
		_set_professor_portrait("Monro", false)
		menu.visible = true

# Button callback: plays the chosen question's dialogue.
func _on_monro_question(question):
	var menu = get_node_or_null("/root/Level1/MonroMenu/QuestionMenu")
	if menu != null:
		menu.visible = false
	if question == 1:
		_start_monro_dialogue("MonroQ1")
	elif question == 2:
		_start_monro_dialogue("MonroQ2")

# Opens the popup on a Monro sub-conversation and shows its first line.
func _start_monro_dialogue(conversation):
	# Restore the portrait for dialogue (it was hidden during the menu).
	_set_professor_portrait("Monro", true)
	init_conversation(conversation)
	launch_popup()
	load_dialog()

# --- Edmonstone question menu helpers (Level 1 only) ---

# Shows the three-question menu. If the portrait has already been unlocked,
# plays a short repeat line instead of offering the menu again.
func _show_edmonstone_menu():
	var menu = get_node_or_null("/root/Level1/EdmonstoneMenu/QuestionMenu")
	if menu == null:
		return
	if edmonstonePortraitUnlocked:
		menu.visible = false
		# Deferred to avoid re-entering load_dialog from inside itself.
		call_deferred("_start_edmonstone_dialogue", "EdmonstoneAfter")
	else:
		globals.canMove = false
		# Hide the portrait so only the centered question panel is shown.
		_set_professor_portrait("Edmonstone", false)
		menu.visible = true

# Button callback: plays the chosen question's dialogue. Question 3 leads into
# the artifact unlock dialogue once it finishes.
func _on_edmonstone_question(question):
	var menu = get_node_or_null("/root/Level1/EdmonstoneMenu/QuestionMenu")
	if menu != null:
		menu.visible = false
	if question == 1:
		_start_edmonstone_dialogue("EdmonstoneQ1")
	elif question == 2:
		_start_edmonstone_dialogue("EdmonstoneQ2")
	elif question == 3:
		_start_edmonstone_dialogue("EdmonstoneQ3")

# Opens the popup on an Edmonstone sub-conversation and shows its first line.
func _start_edmonstone_dialogue(conversation):
	# Restore the portrait for dialogue (it was hidden during the menu).
	_set_professor_portrait("Edmonstone", true)
	init_conversation(conversation)
	launch_popup()
	load_dialog()

# --- Level 1 courtroom character portraits ---

const COURTROOM_CHARS = ["Court", "Darwin", "Morris", "Prosecutor"]
const COURTROOM_FADE = 0.3

# Slot X positions: one centered character, or a clean left/right pair.
const SLOT_CENTER_X = 640
const SLOT_LEFT_X = 360
const SLOT_RIGHT_X = 920
# Common baseline: every portrait's bottom edge sits here, so any two shown
# together look level / grounded on the same plane. Kept above the dialogue box.
const COURTROOM_BASELINE = 550
# When two are shown, the earlier name in this order takes the left slot. This is
# pair-relative (not a fixed side per character): a character can be on the left
# in one pairing and the right in another.
const COURTROOM_ORDER = ["Morris", "Darwin", "Court", "Prosecutor"]
# Per-character scale and native texture height (for baseline alignment).
const CHAR_SCALE = {"Court": 0.8, "Darwin": 0.8, "Morris": 0.8, "Prosecutor": 0.3}
const CHAR_NATIVE_H = {"Court": 360, "Darwin": 360, "Morris": 360, "Prosecutor": 1448}

# Tracks which portraits are currently faded in, so a character that stays on
# screen between lines is not needlessly faded out and back in.
var courtroom_shown = {"Court": false, "Darwin": false, "Morris": false, "Prosecutor": false}

# True while one of the Level 1 courtroom conversations is playing, so the
# speaker-to-portrait logic only runs during the courtroom scene.
func _is_courtroom_convo():
	return main == level1Complete or main == rocksCourtroom or main == boneCourtroom or main == portraitCourtroom

# Strips the [center] bbcode tags from a speaker label and trims whitespace.
func _plain_name(raw):
	return raw.replace("[center]", "").replace("[/center]", "").strip_edges()

func _courtroom_node():
	return get_node_or_null("/root/Level1/CanvasLayer/Courtroom")

# Bottom-aligned position for a character in a given slot, so all portraits share
# a common baseline regardless of their individual scale/height.
func _slot_pos(node_name, slot_x):
	var half_h = CHAR_NATIVE_H[node_name] * CHAR_SCALE[node_name] / 2.0
	return Vector2(slot_x, COURTROOM_BASELINE - half_h)

# Scales the four portraits and starts them fully transparent at the beginning of
# a courtroom conversation. Done in code so Level 2/3 (which share the Courtroom
# node) keep their own authored placement.
func _prepare_courtroom_layout():
	var court_node = _courtroom_node()
	if court_node == null:
		return
	var tween = court_node.get_node_or_null("CharTween")
	if tween != null:
		tween.remove_all()
	for n in COURTROOM_CHARS:
		courtroom_shown[n] = false
		var sprite = court_node.get_node_or_null(n)
		if sprite != null:
			sprite.scale = Vector2(CHAR_SCALE[n], CHAR_SCALE[n])
			sprite.visible = true
			sprite.modulate = Color(1, 1, 1, 0)

# Shows the character PNG(s) that match the current speaker and places them with
# the slot system: one visible character is centered; two are split into left and
# right slots (never the same side, never overlapping). Fades are preserved, and
# a character that must change slot while staying on screen slides smoothly.
func _update_courtroom_speaker(raw_name, line_text):
	var court_node = _courtroom_node()
	if court_node == null:
		return
	var speaker = _plain_name(raw_name)
	var want = {"Court": false, "Darwin": false, "Morris": false, "Prosecutor": false}
	var primary = ""
	if speaker == "Time Travel Court":
		# The court addresses the defense lawyer.
		want["Court"] = true
		want["Morris"] = true
		primary = "Court"
	elif speaker == "Charles Darwin":
		want["Darwin"] = true
		if "Robert" in line_text:
			want["Morris"] = true
		primary = "Darwin"
	elif speaker == "Prosecutor":
		# The prosecutor challenges the defendant.
		want["Prosecutor"] = true
		want["Darwin"] = true
		primary = "Prosecutor"
	else:
		# Player / Robert Morris (the defense lawyer) presenting to the court.
		want["Morris"] = true
		want["Court"] = true
		primary = "Morris"

	# Assign slots: 1 visible -> center; 2 visible -> left + right.
	var visible_names = []
	for n in COURTROOM_ORDER:
		if want[n]:
			visible_names.append(n)
	var slot_x = {}
	if visible_names.size() == 1:
		slot_x[visible_names[0]] = SLOT_CENTER_X
	elif visible_names.size() >= 2:
		slot_x[visible_names[0]] = SLOT_LEFT_X
		slot_x[visible_names[1]] = SLOT_RIGHT_X

	for n in COURTROOM_CHARS:
		var sprite = court_node.get_node_or_null(n)
		if sprite == null:
			continue
		if want[n]:
			# Active speaker draws on top of a paired character.
			sprite.z_index = 1 if n == primary else 0
			var target_pos = _slot_pos(n, slot_x[n])
			if not courtroom_shown[n]:
				# New on screen: snap to its slot (still transparent) then fade in.
				sprite.position = target_pos
				_fade_char(court_node, sprite, true)
			elif sprite.position != target_pos:
				# Already visible but its slot changed: slide over, don't pop.
				_slide_char(court_node, sprite, target_pos)
			courtroom_shown[n] = true
		else:
			if courtroom_shown[n]:
				_fade_char(court_node, sprite, false)
			courtroom_shown[n] = false

# Fades one portrait's modulate alpha in (visible) or out (hidden). Uses the
# Courtroom's Tween node (Godot 3.2 compatible); resets any in-flight fade on
# the same sprite first so rapid line-skipping can't leave alpha stuck.
func _fade_char(court_node, sprite, fade_in):
	var target_a = 1.0 if fade_in else 0.0
	var tween = court_node.get_node_or_null("CharTween")
	if tween == null:
		sprite.modulate = Color(1, 1, 1, target_a)
		return
	tween.remove(sprite, "modulate")
	tween.interpolate_property(sprite, "modulate", sprite.modulate, Color(1, 1, 1, target_a), COURTROOM_FADE, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

# Smoothly slides a still-visible portrait to a new slot (used when a character
# must move, e.g. center -> left when a second character joins the scene).
func _slide_char(court_node, sprite, target_pos):
	var tween = court_node.get_node_or_null("CharTween")
	if tween == null:
		sprite.position = target_pos
		return
	tween.remove(sprite, "position")
	tween.interpolate_property(sprite, "position", sprite.position, target_pos, COURTROOM_FADE, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

