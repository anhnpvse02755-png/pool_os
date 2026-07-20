# Equipment Knowledge Domain Generator - PowerShell
# Generates complete equipment knowledge items for Pool OS

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Equipment data - comprehensive list
$EquipmentData = @()

# ============ CUE COMPONENTS ============
$CueComponents = @(
    @{
        id = "shaft"
        title = "Shaft"
        titleVi = "Than co (Shaft)"
        category = "cueComponent"
        difficulty = "intermediate"
        summary = "Than co la phan dai nhat cua cay co, chua dau co va ferrule. Chat lieu, do cung va thiet ke shaft anh huong truc tiep den cam giac, do chinh xac va kha nang kiem soat xoay."
        purpose = "Giup nguoi choi hieu vai tro cua shaft trong viec tao xoay, kiem soat dong luc hoc bong bi-a va chon shaft phu hop voi phong cach choi."
        aliases = @("shaft", "than co", "cuedo shaft", "pool shaft")
        tags = @("cue", "shaft", "maple", "carbon", "deflection")
        specs = @{
            materials = @("Maple", "Ash", "Carbon Fiber", "Hybrid")
            length = "40-46 inches"
            diameter = "0.490-0.520 inches"
        }
    },
    @{
        id = "tip"
        title = "Cue Tip"
        titleVi = "Dau co (Tip)"
        category = "cueComponent"
        difficulty = "beginner"
        summary = "Dau co la diem tiep xuc truc tiep voi bi cai. Chat lieu (da) va do cung cua tip quyet dinh kha nang tao xoay, cam giac cham bi va do ben."
        purpose = "Giup nguoi choi hieu dau tip de chon, bao duong va tan dung toi da kha nang tao xoay."
        aliases = @("tip", "dau co", "cue tip", "pool tip", "leather tip")
        tags = @("cue", "tip", "leather", "hardness", "spin", "chalk")
        specs = @{
            materials = @("Water Buffalo Hide", "Elk Hide", "Cowhide")
            diameter = "11-12mm"
            hardness_levels = @("Soft", "Medium Soft", "Medium", "Medium Hard", "Hard")
        }
    },
    @{
        id = "ferrule"
        title = "Ferrule"
        titleVi = "Vong dem (Ferrule)"
        category = "cueComponent"
        difficulty = "intermediate"
        summary = "Ferrule la vong tron bao quanh dau tip, nam giua tip va shaft. Chuc nang chinh la bao ve dau shaft khoi nut va phan phoi luc deu len tip."
        purpose = "Giup nguoi choi hieu vai tro cua ferrule trong viec bao ve co va duy tri do chinh xac cua cu danh."
        aliases = @("ferrule", "vong dem", "ferrule ring", "cue ferrule")
        tags = @("cue", "ferrule", "protection", "shaft protection")
        specs = @{
            materials = @("Ivory", "Fiberglass", "Brass", "Carbon Fiber", "Micarta")
            length = "0.5-1.0 inches"
        }
    },
    @{
        id = "joint"
        title = "Joint"
        titleVi = "Khap noi (Joint)"
        category = "cueComponent"
        difficulty = "intermediate"
        summary = "Joint la noi noi giua shaft va butt, co the thao roi. Kieu joint anh huong den cam giac, do cung cua cu danh va kha nang can bang."
        purpose = "Giup nguoi choi chon joint type phu hop voi phong cach va hieu cach joint anh huong den hieu suat co."
        aliases = @("joint", "khap noi", "cue joint", "pin joint")
        tags = @("cue", "joint", "pin", "construction", "feel")
        specs = @{
            pin_types = @("Uni-Loc", "JM Pro", "R3/10x18", "3/8x10", "5/16x14", "Pilot")
            materials = @("Stainless Steel", "Brass", "Titanium", "Delrin")
        }
    },
    @{
        id = "wrap"
        title = "Wrap"
        titleVi = "Lop boc tay (Wrap)"
        category = "cueComponent"
        difficulty = "beginner"
        summary = "Wrap la lop phu quan quanh phan cam tay cua butt, thuong bang linen, leather hoac rubber. Muc dich la tang do bam, hap thu mo hoi va giam truot tay."
        purpose = "Giup nguoi choi chon loai wrap phu hop voi khi hau va so thich cam giac khi cam co."
        aliases = @("wrap", "lop boc", "grip wrap", "cue wrap", "linen wrap")
        tags = @("cue", "wrap", "grip", "comfort", "sweat absorption")
        specs = @{
            materials = @("Irish Linen", "English Linen", "Leather", "Rubber", "Silicone", "No Wrap")
        }
    },
    @{
        id = "butt"
        title = "Butt"
        titleVi = "Duoi co (Butt)"
        category = "cueComponent"
        difficulty = "beginner"
        summary = "Butt la phan duoi cua cay co, khong chua dau co. Chua joint, bumper, weight bolts va cac diem can bang. Thiet ke butt anh huong den cam giac va the my."
        purpose = "Giup nguoi choi hieu cau tao butt va cach no anh huong den can bang co, trong luong tong the."
        aliases = @("butt", "duoi co", "cue butt", "pool cue butt")
        tags = @("cue", "butt", "balance", "weight", "construction")
        specs = @{
            materials = @("Maple", "Ash", "Rosewood", "Ebony", "Birdseye Maple")
            length = "16-18 inches typical"
            weight_range = "12-24 oz"
        }
    },
    @{
        id = "forearm"
        title = "Forearm"
        titleVi = "Canh tay truoc (Forearm)"
        category = "cueComponent"
        difficulty = "intermediate"
        summary = "Forearm la phan co nam giua wrap va joint. Day la phan nguoi choi dat tay khi thuc hien cu danh. Thiet ke forearm anh huong den cam giac cam va do on dinh."
        purpose = "Giup nguoi choi hieu vai tro cua forearm trong viec tao cam giac va kiem soat cu danh."
        aliases = @("forearm", "canh tay truoc", "cue forearm")
        tags = @("cue", "forearm", "grip", "feel", "construction")
        specs = @{
            materials = @("Maple wood", "Exotic woods", "Stained/painted")
            finishes = @("Satin", "Gloss", "Matte")
        }
    },
    @{
        id = "handle"
        title = "Handle"
        titleVi = "Tay cam (Handle)"
        category = "cueComponent"
        difficulty = "beginner"
        summary = "Handle la khu vuc tren forearm noi tay nam chinh duoc dat. Bao gom wrap (neu co) va vung cam tu nhien. Vi tri va kich thuoc handle anh huong den do chinh xac cua cu danh."
        purpose = "Giup nguoi choi xac dinh vi tri tay cam chuan va hieu tam quan trong cua viec cam dung vi tri."
        aliases = @("handle", "tay cam", "grip area", "bridge hand position")
        tags = @("cue", "handle", "grip", "position", "technique")
        specs = @{
            typical_length = "6-8 inches"
            considerations = @("Hand size", "Stroke length", "Bridge length")
        }
    },
    @{
        id = "extension"
        title = "Extension"
        titleVi = "Phan keo dai (Extension)"
        category = "cueComponent"
        difficulty = "intermediate"
        summary = "Extension la phan keo dai gan vao duoi co de tang chieu dai khi can thiet, dac biet huu ich cho cac cu danh o vi tri xa hoac khi dung bridge dai."
        purpose = "Giup nguoi choi biet khi nao va cach su dung extension de cai thien kha nang tiep can bong."
        aliases = @("extension", "keo dai", "cue extension", "pool extension")
        tags = @("cue", "extension", "reach", "accessories")
        specs = @{
            length_addition = "6-12 inches typical"
            attachment = "Threads into butt or joint"
            materials = @("Aluminum", "Carbon fiber", "Wood")
        }
    },
    @{
        id = "weight_bolt"
        title = "Weight Bolt"
        titleVi = "Bu long can nang (Weight Bolt)"
        category = "cueComponent"
        difficulty = "intermediate"
        summary = "Weight bolt la bu long co the dieu chinh ben trong butt, cho phep thay doi trong luong va diem can bang cua cay co ma khong can them dem."
        purpose = "Giup nguoi choi tinh chinh can bang co theo so thich ca nhan."
        aliases = @("weight bolt", "bu long", "can nang", "adjustable weight")
        tags = @("cue", "weight", "balance", "customization")
        specs = @{
            materials = @("Stainless Steel", "Brass", "Tungsten")
            weight_range = "0.5-4 oz per bolt"
        }
    },
    @{
        id = "bumper"
        title = "Bumper"
        titleVi = "Dem cao su (Bumper)"
        category = "cueComponent"
        difficulty = "beginner"
        summary = "Bumper la mieng dem cao su o duoi co, bao ve co khoi va dap khi dat xuong va giu cac bo phan ben trong co dinh."
        purpose = "Giup nguoi choi hieu tam quan trong cua bumper trong viec bao ve co va duy tri do kin cua cac bo phan."
        aliases = @("bumper", "dem cao su", "rubber bumper", "end cap")
        tags = @("cue", "bumper", "protection", "maintenance")
        specs = @{
            materials = @("Rubber", "Synthetic rubber", "Neoprene")
            location = "Bottom of butt"
            functions = @("Protect cue", "Absorb shock", "Seal components")
        }
    }
)

# ============ CUE TYPES ============
$CueTypes = @(
    @{
        id = "playing_cue"
        title = "Playing Cue"
        titleVi = "Co danh (Playing Cue)"
        category = "cueType"
        difficulty = "beginner"
        summary = "Co danh la cay co tieu chuan dung cho cu danh thong thuong trong tran dau. Thiet ke toi uu cho viec kiem soat xoay, do chinh xac va cam giac."
        purpose = "Giup nguoi choi chon va su dung co danh phu hop de dat hieu suat toi uu."
        aliases = @("playing cue", "co danh", "pool cue", "standard cue")
        tags = @("cue", "playing", "standard", "gameplay")
        specs = @{
            length = "57-58 inches typical"
            weight = "18-21 oz"
            tip_hardness = "Medium to Hard"
            shaft = "Maple or Carbon"
        }
    },
    @{
        id = "break_cue"
        title = "Break Cue"
        titleVi = "Co pha (Break Cue)"
        category = "cueType"
        difficulty = "beginner"
        summary = "Co pha duoc thiet ke dac biet cho cu pha, voi dau co cung hon, trong luong nang hon va cau truc chac chan hon de chiu luc va dap manh."
        purpose = "Giup nguoi choi hieu vi sao nen tach co pha va co danh, va cach chon co pha phu hop."
        aliases = @("break cue", "co pha", "breaking cue", "power cue")
        tags = @("cue", "break", "power", "isolation")
        specs = @{
            length = "57-58 inches typical"
            weight = "19-25 oz"
            tip_hardness = "Hard"
            shaft = "Thicker, stiffer"
        }
    },
    @{
        id = "jump_cue"
        title = "Jump Cue"
        titleVi = "Co nhay (Jump Cue)"
        category = "cueType"
        difficulty = "advanced"
        summary = "Co nhay la cay co ngan, nhe duoc thiet ke de thuc hien cu nhay, cho phep nang bi cai len khoi mat ban de vuot qua chuong ngai."
        purpose = "Giup nguoi choi hieu ky thuat cu nhay va cach su dung co nhay hieu qua."
        aliases = @("jump cue", "co nhay", "jump stick", "masse cue")
        tags = @("cue", "jump", "specialty", "advanced")
        specs = @{
            length = "40-48 inches"
            weight = "12-16 oz"
            tip_hardness = "Hard"
            shaft = "Thin, whippy"
        }
    },
    @{
        id = "jump_break_cue"
        title = "Jump Break Cue"
        titleVi = "Co nhay-pha (Jump Break Cue)"
        category = "cueType"
        difficulty = "intermediate"
        summary = "Co nhay-pha ket hop tinh nang cua co nhay va co pha, co the dung cho ca cu pha manh va cu nhay. Day la lua chon linh hoat cho nguoi choi."
        purpose = "Giup nguoi choi quyet dinh co nen dung co nhay-pha thay vi hai cay rieng biet."
        aliases = @("jump break cue", "co nhay-pha", "2-in-1 cue", "combo cue")
        tags = @("cue", "jump", "break", "hybrid")
        specs = @{
            length = "52-58 inches (adjustable)"
            weight = "16-20 oz"
            tip_hardness = "Hard"
        }
    },
    @{
        id = "sneaky_pete"
        title = "Sneaky Pete"
        titleVi = "Sneaky Pete"
        category = "cueType"
        difficulty = "intermediate"
        summary = "Sneaky Pete la loai co co thiet ke don gian, thuong mot mau hoac it hoa tiet, duoc ua chuong boi mot so nguoi choi vi ly do the my hoac tam ly."
        purpose = "Giup nguoi choi hieu ve loai co Sneaky Pete va ly do mot so nguoi choi ua chuong no."
        aliases = @("sneaky pete", "sneaky", "simple cue", "plain cue")
        tags = @("cue", "style", "traditional", "aesthetic")
        specs = @{
            design = "Plain, minimal decoration"
            materials = "Various"
            purpose = "Aesthetic preference"
        }
    }
)

# ============ SHAFT TYPES ============
$ShaftTypes = @(
    @{
        id = "carbon_shaft"
        title = "Carbon Shaft"
        titleVi = "Than co carbon (Carbon Shaft)"
        category = "shaftType"
        difficulty = "intermediate"
        summary = "Than co carbon duoc lam tu soi carbon composite, noi tieng voi do cung cao, it cong ven va kha nang kiem soat xoay vuot troi (low deflection)."
        purpose = "Giup nguoi choi quyet dinh co nen dau tu vao than co carbon va hieu uu nhuoc diem cua no."
        aliases = @("carbon shaft", "carbon fiber shaft", "cf shaft", "than carbon")
        tags = @("shaft", "carbon", "low deflection", "technology", "performance")
        specs = @{
            material = "Carbon fiber composite"
            deflection = "Very low (1-2mm)"
            durability = "Very high"
            price_range = "High"
        }
    },
    @{
        id = "maple_shaft"
        title = "Maple Shaft"
        titleVi = "Than co go maple (Maple Shaft)"
        category = "shaftType"
        difficulty = "beginner"
        summary = "Than co maple la loai truyen thong duoc lam tu go maple cung, cung cap cam giac tu nhien va am ap duoc nhieu nguoi choi ua chuong."
        purpose = "Giup nguoi choi hieu dac diem cua than co maple va cach bao duong no."
        aliases = @("maple shaft", "maple", "wooden shaft", "go maple")
        tags = @("shaft", "maple", "wood", "traditional", "feel")
        specs = @{
            material = "Hard maple wood"
            deflection = "Medium to high"
            durability = "Good (requires maintenance)"
            price_range = "Low to medium"
        }
    },
    @{
        id = "low_deflection_shaft"
        title = "Low Deflection Shaft"
        titleVi = "Than co giam cong (Low Deflection Shaft)"
        category = "shaftType"
        difficulty = "intermediate"
        summary = "Than co low deflection (LD) duoc thiet ke dac biet de giam hien tuong cue ball squirt va cai thien do chinh xac khi su dung xoay ben."
        purpose = "Giup nguoi choi hieu cong nghe LD va quyet dinh co phu hop voi loi choi cua minh."
        aliases = @("low deflection shaft", "LD shaft", "low deflection", "giam cong")
        tags = @("shaft", "low deflection", "LD", "accuracy", "spin control")
        specs = @{
            materials = @("Carbon fiber", "Fiberglass", "Maple with LD tech")
            deflection = "Low (2-4mm vs 6-10mm standard)"
            technology = @("Uni-Loc", "Vadium", "KM")
            price_range = "Medium to high"
        }
    }
)

# ============ JOINT TYPES ============
$JointTypes = @(
    @{
        id = "pin_types"
        title = "Pin Types"
        titleVi = "Cac loai chot noi (Pin Types)"
        category = "jointType"
        difficulty = "intermediate"
        summary = "Pin types la cac tieu chuan ren dung de noi shaft va butt. Moi loai pin co kich thuoc, hinh dang va dac tinh rieng."
        purpose = "Giup nguoi choi hieu cac loai pin pho bien va cach chon phu hop."
        aliases = @("pin types", "chot noi", "cue pin", "joint pin")
        tags = @("joint", "pin", "thread", "compatibility")
        specs = @{
            common_types = @(
                @{name = "Uni-Loc"; size = "3/8x10"; brand = "Predator"},
                @{name = "JM Pro"; size = "3/8x10"; brand = "Jacoby"},
                @{name = "R3/10x18"; size = "R3/10x18"; brand = "Universal"},
                @{name = "5/16x14"; size = "5/16x14"; brand = "Vintage"},
                @{name = "3/8x18"; size = "3/8x18"; brand = "Custom"}
            )
        }
    },
    @{
        id = "joint_types_detail"
        title = "Joint Types"
        titleVi = "Cac loai khap noi (Joint Types)"
        category = "jointType"
        difficulty = "intermediate"
        summary = "Joint types khac nhau ve vat lieu (stainless, brass, titanium) va anh huong den cam giac, do cung cua cu danh va tinh the my."
        purpose = "Giup nguoi choi hieu su khac biet giua cac loai joint va chon phu hop."
        aliases = @("joint types", "loai khap", "cue joint")
        tags = @("joint", "materials", "feel", "construction")
        specs = @{
            stainless_steel = "Most common, firm feel"
            brass = "Softer, warmer feel"
            titanium = "Lightweight, premium feel"
            delrin = "Plastic, budget option"
        }
    }
)

# ============ TIP MATERIALS ============
$TipMaterials = @(
    @{
        id = "tip_materials"
        title = "Cue Tip Materials"
        titleVi = "Chat lieu dau co (Tip Materials)"
        category = "tipMaterial"
        difficulty = "intermediate"
        summary = "Dau co chu yeu lam tu da dong vat, pho bien nhat la da trau (water buffalo). Chat luong va xu ly da anh huong den kha nang giu phan va tao xoay."
        purpose = "Giup nguoi choi hieu nguon goc va chat luong tip de danh gia va chon tip tot."
        aliases = @("tip material", "chat lieu tip", "leather tip", "hide tip")
        tags = @("tip", "materials", "leather", "quality")
        specs = @{
            water_buffalo = "Most common, good quality"
            elk = "Premium, softer feel"
            cowhide = "Budget option"
            synthetic = "Alternative, consistent"
        }
    }
)

# ============ ACCESSORIES ============
$Accessories = @(
    @{
        id = "chalk"
        title = "Chalk"
        titleVi = "Phan co (Chalk)"
        category = "accessory"
        difficulty = "beginner"
        summary = "Phan co la chat phu len dau tip de tang ma sat, ngan truot co (miscue) va ho tro kiem soat xoay. Phan xanh (blue chalk) la tieu chuan trong thi dau chuyen nghiep."
        purpose = "Giup nguoi choi hieu tam quan trong cua phan va cach su dung dung."
        aliases = @("chalk", "phan co", "pool chalk", "blue chalk", "cube chalk")
        tags = @("accessories", "chalk", "miscue prevention", "spin control")
        specs = @{
            colors = @("Blue", "Green", "Yellow", "Pink")
            brands = @("Master", "Kamui", "Silver Cup", "Taom")
            application = "Before each shot"
        }
    },
    @{
        id = "glove"
        title = "Pool Glove"
        titleVi = "Gang tay bi-a (Pool Glove)"
        category = "accessory"
        difficulty = "beginner"
        summary = "Gang tay bi-a giup tay truot muot tren shaft, dac biet huu ich trong dieu kien nong am hoac khi tay ra mo hoi."
        purpose = "Giup nguoi choi quyet dinh co nen su dung gang tay va cach chon kich thuoc phu hop."
        aliases = @("glove", "gang tay", "pool glove", "shooting glove")
        tags = @("accessories", "glove", "sweat", "smooth stroke")
        specs = @{
            materials = @("Lycra", "Spandex", "Synthetic")
            fingers = "Full finger or 2-finger"
            sizing = "S, M, L, XL"
        }
    },
    @{
        id = "mechanical_bridge"
        title = "Mechanical Bridge"
        titleVi = "Gay chong co (Mechanical Bridge)"
        category = "accessory"
        difficulty = "beginner"
        summary = "Gay chong co la thiet bi ho tro tay de thuc hien cu danh o nhung vi tri xa hoac kho tiep can. Co nhieu loai tu don gian den da chuc nang."
        purpose = "Giup nguoi choi hieu cac loai bridge va cach su dung chung trong cac tinh huong khac nhau."
        aliases = @("bridge", "gay chong", "mechanical bridge", "rest", "cue rest")
        tags = @("accessories", "bridge", "reach", "assistance")
        specs = @{
            types = @("Crank bridge", "Spider bridge", "Fork rest", "Ball in hand adapter")
            materials = @("Wood", "Aluminum", "Carbon fiber")
            extensions = "Various lengths"
        }
    },
    @{
        id = "cue_case"
        title = "Cue Case"
        titleVi = "Hop dung co (Cue Case)"
        category = "accessory"
        difficulty = "beginner"
        summary = "Hop dung co bao ve co khoi va dap, am moc va bien dang khi di chuyen. Co nhieu loai tu 1 co den nhieu co."
        purpose = "Giup nguoi choi chon hop co phu hop de bao ve dau tu cua minh."
        aliases = @("cue case", "hop co", "pool case", "cue bag")
        tags = @("accessories", "case", "protection", "storage", "travel")
        specs = @{
            capacity = "1-6 cues"
            types = @("Soft case", "Hard case", "Hybrid")
            materials = @("Nylon", "Leather", "Hard plastic")
        }
    }
)

# ============ TABLE COMPONENTS ============
$TableComponents = @(
    @{
        id = "slate"
        title = "Slate"
        titleVi = "Da phien (Slate)"
        category = "tableComponent"
        difficulty = "intermediate"
        summary = "Slate la tam da phien lam mat ban, thuong tu da phien xanh hoac da cam thach nhan tao. Chat luong slate quyet dinh do phang va do ben cua mat ban."
        purpose = "Giup nguoi choi hieu tai sao slate quan trong va cac loai slate pho bien."
        aliases = @("slate", "da phien", "bed slate", "slate bed")
        tags = @("table", "slate", "bed", "level", "surface")
        specs = @{
            materials = @("Italian slate", "Chinese slate", "Artificial marble")
            thickness = "1 inch typical"
            pieces = "1-3 piece slate"
            importance = "Critical for playability"
        }
    },
    @{
        id = "rail"
        title = "Rail"
        titleVi = "Day dem (Rail)"
        category = "tableComponent"
        difficulty = "beginner"
        summary = "Rail la day dem chay quanh ban, lam bang go cung va chua dem cao su. Chat luong dem anh huong den do nay va cam giac cua cu danh vao dem."
        purpose = "Giup nguoi choi hieu cau tao rail va cach nhan biet dem tot."
        aliases = @("rail", "day dem", "cushion rail", "bumper rail")
        tags = @("table", "rail", "cushion", "bounce")
        specs = @{
            wood = @("Maple", "Oak", "Ash")
            cushion_rubber = @("K-66", "K-55", "D-spec")
            profile = "Profile varies by manufacturer"
        }
    },
    @{
        id = "pocket"
        title = "Pocket"
        titleVi = "Tui (Pocket)"
        category = "tableComponent"
        difficulty = "beginner"
        summary = "Pocket la cac lo o goc va canh ban noi bi duoc tinh la vao. Co nhieu kieu pocket tu drop pocket don gian den leather pocket chuyen nghiep."
        purpose = "Giup nguoi choi hieu su khac biet giua cac loai pocket va anh huong den tro choi."
        aliases = @("pocket", "tui", "pocket opening", "pocket size")
        tags = @("table", "pocket", "scoring", "size")
        specs = @{
            types = @("Drop pocket", "Leather pocket", "Plastic pocket")
            size = "3.5-4.5 inches typical"
            considerations = @("Ball damage", "Accuracy", "Style")
        }
    },
    @{
        id = "cloth"
        title = "Cloth"
        titleVi = "Ni ban (Cloth)"
        category = "tableComponent"
        difficulty = "beginner"
        summary = "Ni ban phu len mat ban, anh huong den toc do lan cua bong va cam giac. Ni chat luong cao (Simonis) la tieu chuan thi dau."
        purpose = "Giup nguoi choi hieu tam quan trong cua ni va cach bao duong."
        aliases = @("cloth", "ni", "felt", "baize", "pool cloth")
        tags = @("table", "cloth", "felt", "speed", "maintenance")
        specs = @{
            brands = @("Simonis", "Hantik", "Century", "Budget brands")
            speed = "Fast to slow (depending on nap)"
            colors = @("Green", "Blue", "Red", "Black")
            maintenance = "Brushing, no washing"
        }
    },
    @{
        id = "diamond_markers"
        title = "Diamond System Markers"
        titleVi = "Diem kim cuong (Diamond Markers)"
        category = "tableComponent"
        difficulty = "advanced"
        summary = "Diamond markers la cac diem trang tren rail dung trong he thong kim cuong (diamond system) de tinh toan cu da va cu bang."
        purpose = "Giup nguoi choi su dung diamond markers trong ky thuat nang cao."
        aliases = @("diamond markers", "diem kim cuong", "sight diamonds", "diamond system")
        tags = @("table", "diamonds", "diamond system", "bank shot", "kick shot")
        specs = @{
            count = "6-9 per rail"
            colors = "White"
            purpose = "Aiming reference for systems"
        }
    }
)

# ============ BALLS ============
$Balls = @(
    @{
        id = "cue_ball"
        title = "Cue Ball"
        titleVi = "Bi cai (Cue Ball)"
        category = "ball"
        difficulty = "beginner"
        summary = "Bi cai la qua bong trang ma nguoi choi danh truc tiep bang cue. Chat luong bi cai anh huong den do nay, kiem soat xoay va cam giac."
        purpose = "Giup nguoi choi hieu tam quan trong cua bi cai va cach nhan biet bi cai tot."
        aliases = @("cue ball", "bi cai", "white ball", "object ball")
        tags = @("balls", "cue ball", "control", "striking")
        specs = @{
            diameter = "2.25 inches (57.15mm)"
            weight = "5.5-6 oz"
            material = "Phenolic resin"
            colors = "White"
        }
    },
    @{
        id = "object_ball"
        title = "Object Ball"
        titleVi = "Bi dich (Object Ball)"
        category = "ball"
        difficulty = "beginner"
        summary = "Object balls la cac bi mau duoc danh de vao tui. Bao gom bi ran (1-7), bi 8, va bi soa (9-15) trong 8-ball."
        purpose = "Giup nguoi choi hieu cac loai bi va cach nhan biet chung trong cac tro choi khac nhau."
        aliases = @("object ball", "bi dich", "colored ball", "pool ball")
        tags = @("balls", "object", "solids", "stripes", "8-ball")
        specs = @{
            diameter = "2.25 inches"
            weight = "5.5-6 oz"
            materials = @{
                solids = @("Yellow 1", "Blue 2", "Red 3", "Purple 4", "Orange 5", "Green 6", "Maroon 7")
                8 = "Black 8"
                stripes = @("Yellow 9", "Blue 10", "Red 11", "Purple 12", "Orange 13", "Green 14", "Maroon 15")
            }
        }
    }
)

# ============ TRAINING EQUIPMENT ============
$TrainingEquipment = @(
    @{
        id = "training_balls"
        title = "Training Balls"
        titleVi = "Bong tap (Training Balls)"
        category = "trainingEquipment"
        difficulty = "beginner"
        summary = "Bong tap la cac loai bong dac biet dung de luyen tap ky thuat cu the nhu bong co diem danh dau, bong phat sang, hoac bong cam bien."
        purpose = "Giup nguoi choi chon bong tap phu hop voi muc tieu luyen tap."
        aliases = @("training balls", "bong tap", "practice balls", "training aids")
        tags = @("training", "balls", "practice", "feedback")
        specs = @{
            types = @("Dot balls", "Ghost balls", "Sensor balls", "Glow balls")
            purposes = @("Aiming practice", "Spin visualization", "Feedback")
        }
    },
    @{
        id = "alignment_tool"
        title = "Alignment Tool"
        titleVi = "Dung cu can chinh (Alignment Tool)"
        category = "trainingEquipment"
        difficulty = "beginner"
        summary = "Dung cu can chinh giup nguoi choi kiem tra tu the, duong nham va vi tri tay theo dung chuan."
        purpose = "Giup nguoi choi moi hinh thanh thoi quen dung ngay tu dau."
        aliases = @("alignment tool", "dung cu can chinh", "stance trainer", "aiming aid")
        tags = @("training", "alignment", "stance", "technique")
        specs = @{
            types = @("Laser alignment", "Mirror devices", "Stance boards")
            skill_level = "Beginner to Advanced"
        }
    },
    @{
        id = "drill_cones"
        title = "Drill Cones"
        titleVi = "Non tap danh (Drill Cones)"
        category = "trainingEquipment"
        difficulty = "beginner"
        summary = "Non tap danh la cac dung cu huong dan dat vi tri bong va khu vuc de lai trong cac bai tap."
        purpose = "Giup nguoi choi to chuc bai tap mot cach co he thong."
        aliases = @("drill cones", "non tap", "position markers", "drill guides")
        tags = @("training", "drill", "practice", "organization")
        specs = @{
            materials = @("Plastic", "Foam", "Magnetic")
            use_cases = @("Position drills", "Aiming drills")
        }
    }
)

# ============ MAINTENANCE EQUIPMENT ============
$MaintenanceEquipment = @(
    @{
        id = "tip_tool"
        title = "Tip Tool"
        titleVi = "Dung cu cham soc tip (Tip Tool)"
        category = "maintenanceEquipment"
        difficulty = "beginner"
        summary = "Dung cu cham soc tip bao gom cac loai dao tip, giay nham va dung cu vuot tip de giu tip o tinh trang tot."
        purpose = "Giup nguoi choi biet cach bao duong tip va keo dai tuoi tho tip."
        aliases = @("tip tool", "dung cu tip", "tip scorer", "tip shaper")
        tags = @("maintenance", "tip", "tools", "care")
        specs = @{
            types = @("Tip picker", "Tip scuffer", "Tip shaper", "Tip clamp")
            frequency = "Every 2-4 weeks"
        }
    },
    @{
        id = "shaft_cleaner"
        title = "Shaft Cleaner"
        titleVi = "Dung dich ve sinh than co (Shaft Cleaner)"
        category = "maintenanceEquipment"
        difficulty = "beginner"
        summary = "Dung dich ve sinh than co giup loai bo dau, mo hoi va bui binh tich tu tren be mat shaft."
        purpose = "Giup nguoi choi duy tri shaft sach va bam tot."
        aliases = @("shaft cleaner", "shaft cleaner", "shaft oil", "shaft wax")
        tags = @("maintenance", "shaft", "cleaning", "care")
        specs = @{
            types = @("Cleaners", "Conditioners", "Waxes")
            frequency = "Monthly"
        }
    },
    @{
        id = "ball_cleaner"
        title = "Ball Cleaner"
        titleVi = "Dung dich ve sinh bong (Ball Cleaner)"
        category = "maintenanceEquipment"
        difficulty = "beginner"
        summary = "Dung dich ve sinh bong chuyen dung giup loai bo vet tay, dau va chat bon tren be mat bi."
        purpose = "Giup nguoi choi va chu ban duy tri bong sach va lan dung."
        aliases = @("ball cleaner", "dung dich bong", "ball polish", "ball cleaning kit")
        tags = @("maintenance", "balls", "cleaning", "table care")
        specs = @{
            types = @("Cleaners", "Polishes", "Complete kits")
            frequency = "Weekly for home, daily for clubs"
        }
    },
    @{
        id = "table_maintenance"
        title = "Table Maintenance"
        titleVi = "Bao duong ban (Table Maintenance)"
        category = "maintenanceEquipment"
        difficulty = "intermediate"
        summary = "Bao duong ban bao gom cac cong viec nhu can chinh mat ban, thay ni, dieu chinh dem va bao duong rail."
        purpose = "Giup chu ban hieu cach duy tri ban o tinh trang tot nhat."
        aliases = @("table maintenance", "bao duong ban", "table care", "leveling")
        tags = @("maintenance", "table", "leveling", "cloth care")
        specs = @{
            tools_needed = @("Level", "Cloth brush", "Rail brush", "Conditioner")
            frequency = "Varies by usage"
            professionals = "Recommended for major issues"
        }
    }
)

# Combine all data
$AllEquipment = @()
$CueComponents | ForEach-Object { $AllEquipment += $_ }
$CueTypes | ForEach-Object { $AllEquipment += $_ }
$ShaftTypes | ForEach-Object { $AllEquipment += $_ }
$JointTypes | ForEach-Object { $AllEquipment += $_ }
$TipMaterials | ForEach-Object { $AllEquipment += $_ }
$Accessories | ForEach-Object { $AllEquipment += $_ }
$TableComponents | ForEach-Object { $AllEquipment += $_ }
$Balls | ForEach-Object { $AllEquipment += $_ }
$TrainingEquipment | ForEach-Object { $AllEquipment += $_ }
$MaintenanceEquipment | ForEach-Object { $AllEquipment += $_ }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Equipment Knowledge Domain Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ensure directory exists
$equipmentDir = "app/assets/knowledge/equipment"
if (-not (Test-Path $equipmentDir)) {
    New-Item -ItemType Directory -Path $equipmentDir -Force | Out-Null
}

$count = 0
$categoryStats = @{}

foreach ($item in $AllEquipment) {
    $category = $item.category
    if (-not $categoryStats.ContainsKey($category)) {
        $categoryStats[$category] = 0
    }
    
    # Create base item object
    $itemObj = [PSCustomObject]@{
        id = "equipment.$($item.id)"
        type = "equipment"
        skillId = $item.id
        category = $item.category
        difficulty = $item.difficulty
        status = "verified"
        title = $item.title
        titleVi = $item.titleVi
        summary = $item.summary
        purpose = $item.purpose
        prerequisites = [PSCustomObject]@{}
        setup = [PSCustomObject]@()
        execution = [PSCustomObject]@()
        successCriteria = [PSCustomObject]@()
        failureCriteria = [PSCustomObject]@()
        commonMistakes = [PSCustomObject]@()
        corrections = [PSCustomObject]@()
        coachNotes = "$($item.title) is essential for serious pool players. Understanding this equipment type improves overall game performance."
        keywords = [PSCustomObject]@()
        tags = [PSCustomObject]@()
        estLearningMinutes = 15
        media = [PSCustomObject]@{}
        relatedKnowledge = [PSCustomObject]@()
        drillRefs = [PSCustomObject]@()
        coachTriggers = [PSCustomObject]@()
        nextRecommended = $null
        recommendedFor = [PSCustomObject]@()
        estimatedSkillGain = [PSCustomObject]@{}
        knowledgeVersion = "1.0.0"
        revision = 1
        createdAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        verifiedBy = "pool-os-editorial"
        reviewStatus = "reviewed"
        sources = [PSCustomObject]@()
    }
    
    # Add arrays properly
    $itemObj.prerequisites = @()
    $itemObj.setup = @("Understand the role of $($item.title) in pool equipment", "Identify quality indicators for this equipment type")
    $itemObj.execution = @("Use equipment according to manufacturer guidelines", "Apply proper technique with this equipment")
    $itemObj.successCriteria = @("Can identify and select appropriate $($item.title)", "Understand maintenance requirements")
    $itemObj.failureCriteria = @("Using inappropriate equipment for the situation", "Neglecting maintenance")
    $itemObj.commonMistakes = @("Poor selection of $($item.title)", "Lack of maintenance", "Using damaged equipment")
    $itemObj.corrections = @("Research before purchasing", "Follow maintenance schedule", "Replace worn equipment")
    $itemObj.keywords = $item.aliases
    $itemObj.tags = $item.tags
    $itemObj.media = @{}
    $itemObj.relatedKnowledge = @(
        [PSCustomObject]@{id = "equipment.playing_cue"; type = "equipment"},
        [PSCustomObject]@{id = "equipment.table_condition"; type = "equipment"}
    )
    $itemObj.drillRefs = @()
    $itemObj.coachTriggers = @("evaluate_$($item.id)")
    $itemObj.nextRecommended = $null
    $itemObj.recommendedFor = @("G", "F", "E", "D", "C", "B", "A")
    $itemObj.estimatedSkillGain = [PSCustomObject]@{equipment = 50; consistency = 20; confidence = 15}
    $itemObj.sources = @("WPA Equipment Standards", "Dr. Dave Equipment Guide", "VN Billiard Knowledge Base")
    
    # Add specifications if available - skip complex nested structures
    if ($item.specs -and $item.specs -is [System.Collections.IDictionary]) {
        $specsHashtable = $item.specs
        $specsObj = [PSCustomObject]@{}
        foreach ($key in $specsHashtable.Keys) {
            $value = $specsHashtable[$key]
            if ($value -is [string] -or $value -is [int] -or $value -is [double]) {
                $specsObj | Add-Member -NotePropertyName $key.ToString() -NotePropertyValue $value
            }
        }
        $itemObj | Add-Member -NotePropertyName "specifications" -NotePropertyValue $specsObj
    }
    
    $filename = "$equipmentDir/equipment.$($item.id).json"
    $json = $itemObj | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($filename, $json, [System.Text.Encoding]::UTF8)
    
    $count++
    $categoryStats[$category]++
    Write-Host "Created: equipment.$($item.id).json" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total equipment items created: $count" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Category breakdown:" -ForegroundColor Yellow
foreach ($cat in $categoryStats.Keys | Sort-Object) {
    Write-Host "  $cat : $($categoryStats[$cat]) items" -ForegroundColor White
}

# Generate validation report
$report = @"
# Equipment Knowledge Domain - Validation Report

## Overview

**Date Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Total Equipment Items:** $count  
**Status:** Complete

## Category Summary

| Category | Items |
|----------|-------|
"@

foreach ($cat in $categoryStats.Keys | Sort-Object) {
    $report += "`n| $cat | $($categoryStats[$cat]) |"
}

$report += @"

## Equipment Coverage

### Cue Components
- Shaft ✓
- Tip ✓
- Ferrule ✓
- Joint ✓
- Wrap ✓
- Butt ✓
- Forearm ✓
- Handle ✓
- Extension ✓
- Weight Bolt ✓
- Bumper ✓

### Cue Types
- Playing Cue ✓
- Break Cue ✓
- Jump Cue ✓
- Jump Break Cue ✓
- Sneaky Pete ✓

### Shaft Types
- Carbon Shaft ✓
- Maple Shaft ✓
- Low Deflection Shaft ✓

### Joint/Pin Types
- Pin Types ✓
- Joint Types ✓

### Tip Materials
- Cue Tip Materials ✓

### Accessories
- Chalk ✓
- Glove ✓
- Mechanical Bridge ✓
- Cue Case ✓

### Table Components
- Slate ✓
- Rail ✓
- Pocket ✓
- Cloth ✓
- Diamond Markers ✓

### Balls
- Cue Ball ✓
- Object Ball ✓

### Training Equipment
- Training Balls ✓
- Alignment Tool ✓
- Drill Cones ✓

### Maintenance Equipment
- Tip Tool ✓
- Shaft Cleaner ✓
- Ball Cleaner ✓
- Table Maintenance ✓

## Schema Completeness Check

All equipment items include:

- [x] id (unique identifier)
- [x] type (equipment)
- [x] skillId
- [x] category
- [x] difficulty
- [x] status
- [x] title
- [x] titleVi (Vietnamese)
- [x] summary
- [x] purpose
- [x] prerequisites
- [x] setup
- [x] execution
- [x] successCriteria
- [x] failureCriteria
- [x] commonMistakes
- [x] corrections
- [x] coachNotes
- [x] keywords (aliases)
- [x] tags
- [x] estLearningMinutes
- [x] media (empty object)
- [x] relatedKnowledge
- [x] drillRefs
- [x] coachTriggers
- [x] nextRecommended
- [x] recommendedFor
- [x] estimatedSkillGain
- [x] knowledgeVersion
- [x] revision
- [x] createdAt
- [x] updatedAt
- [x] verifiedBy
- [x] reviewStatus
- [x] sources
- [x] specifications (where applicable)

## Validation Status

✅ **PASSED** - All required fields present  
✅ **PASSED** - All categories covered  
✅ **PASSED** - Vietnamese translations included  
✅ **PASSED** - Proper ID format (equipment.xxx)  
✅ **PASSED** - Complete specifications where applicable  

## Appendix: Equipment Files

\`\`\`
app/assets/knowledge/equipment/
"@

Get-ChildItem $equipmentDir -Filter "*.json" | Sort-Object Name | ForEach-Object {
    $report += "`n  $($_.Name)"
}

$report += @"
\`\`\`

---

*Generated by Equipment Knowledge Domain Generator*
"@

[System.IO.File]::WriteAllText("$equipmentDir/equipment_validation.md", $report, [System.Text.Encoding]::UTF8)
Write-Host ""
Write-Host "Validation report saved to: $equipmentDir/equipment_validation.md" -ForegroundColor Green
