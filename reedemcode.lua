local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Codes = {
    "Sub2Fer999",
    "KITT_RESET",
    "CHANDLER",
    "Sub2CaptainMawi",
    "Sub2OfficialNoobie",
    "THEBIGACE",
    "STRAWHATMAINE",
    "SUB2NOOBMASTER123",
    "SUB2UNCLEKIZARU",
    "Sub2Daigrock",
    "Axiore",
    "TantaiGaming",
    "BLUXXY",
    "FUDD10",
    "FUDD10_PRODBYXUAN",
    "BIGNEWS",
    "MAGICBUS",
    "Starcodeheo",
    "JCWK",
    "KITTGAMING",
    "SEATROLLING",
    "24NOOB",
    "ADMIN_STRENGTH",
    "NOOB_REFRESH",
    "15B_BESTBROTHERS"
}

task.spawn(function()
    for _, code in ipairs(Codes) do
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("RedeemCode", code)
        end)
        task.wait(0.5)
    end
end)
