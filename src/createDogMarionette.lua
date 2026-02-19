--!strict
local ChangeHistoryService = game:GetService("ChangeHistoryService")

export type DogConfig = {
	HeadColor: Color3,
	BodyColor: Color3,
	LegsColor: Color3,
	HandlesColor: Color3,
	OverallScale: number,
	LegLength: number,
	SnoutLength: number,
}

local function createDogMarionette(config: DogConfig)
	local S = config.OverallScale
	local LL = config.LegLength
	local SL = config.SnoutLength

	-- Find ground level from the Baseplate (fall back to standard Y=0.5)
	local groundY = 0.5
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		groundY = baseplate.Position.Y + baseplate.Size.Y / 2
	end

	-- Place in front of the camera.
	-- OY is chosen so paw bottoms are exactly 1 stud above the ground:
	--   paw_bottom = OY - S*(2 + 7.5*LL)  =>  OY = groundY + 1 + S*(2 + 7.5*LL)
	local camera = workspace.CurrentCamera
	local OX, OZ = 0, 0
	if camera then
		local target = camera.CFrame * CFrame.new(0, 0, -25)
		OX = target.Position.X
		OZ = target.Position.Z
	end
	local OY = groundY + 1 + S * (2 + 7.5 * LL)

	local recording = ChangeHistoryService:TryBeginRecording("Create Dog Marionette")

	local folder = Instance.new("Folder")
	folder.Name = "DogMarionette"
	folder.Parent = workspace

	local function mkPart(name: string, sz: Vector3, pos: Vector3, color: Color3, anchored: boolean?): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Size = sz
		p.CFrame = CFrame.new(pos)
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = anchored == true
		p.CanCollide = false
		p.Parent = folder
		return p
	end

	local function mkAtt(name: string, parent: Instance, lpos: Vector3): Attachment
		local a = Instance.new("Attachment")
		a.Name = name
		a.Position = lpos
		a.Parent = parent
		return a
	end

	local function mkAttCF(name: string, parent: Instance, cf: CFrame): Attachment
		local a = Instance.new("Attachment")
		a.Name = name
		a.CFrame = cf
		a.Parent = parent
		return a
	end

	local function mkHinge(name: string, a0: Attachment, a1: Attachment, container: Instance)
		local h = Instance.new("HingeConstraint")
		h.Name = name
		h.Attachment0 = a0
		h.Attachment1 = a1
		h.Parent = container
	end

	local function mkBall(name: string, a0: Attachment, a1: Attachment, container: Instance)
		local b = Instance.new("BallSocketConstraint")
		b.Name = name
		b.Attachment0 = a0
		b.Attachment1 = a1
		b.Parent = container
	end

	local function mkRope(name: string, a0: Attachment, a1: Attachment, len: number, container: Instance)
		local r = Instance.new("RopeConstraint")
		r.Name = name
		r.Attachment0 = a0
		r.Attachment1 = a1
		r.Visible = true
		r.Thickness = 0.05
		r.Length = len
		r.Parent = container
	end

	local function mkDrag(p: Instance)
		local d = Instance.new("DragDetector")
		d.DragStyle = Enum.DragDetectorDragStyle.TranslateViewPlane
		d.MaxActivationDistance = 1000
		d.Parent = p
	end

	local function mkWeld(p0: BasePart, p1: BasePart)
		local w = Instance.new("WeldConstraint")
		w.Part0 = p0
		w.Part1 = p1
		w.Parent = folder
	end

	-- Dimensions
	local UL_HALF = 2 * S * LL
	local LL_HALF = 1.75 * S * LL

	-- Body
	local body = mkPart("Body", Vector3.new(4*S, 3*S, 8*S), Vector3.new(OX, OY, OZ), config.BodyColor)
	mkDrag(body)

	-- Head (body front face at OZ+4*S, head half-z=1.5*S → center at OZ+5.5*S)
	local headPos = Vector3.new(OX, OY + 0.3*S, OZ + 5.5*S)
	local head = mkPart("Head", Vector3.new(3.5*S, 3.5*S, 3*S), headPos, config.HeadColor)
	mkDrag(head)

	-- Snout (welded to head; center at head front + half-snout-z)
	-- Head front face: headPos.Z + 1.5*S = OZ + 7*S
	local snoutHalfZ = 1.25 * S * SL
	local snout = mkPart(
		"Snout",
		Vector3.new(2*S, 1.5*S, 2.5*S*SL),
		Vector3.new(OX, OY - 0.4*S, OZ + 7*S + snoutHalfZ),
		config.HeadColor
	)
	mkWeld(head, snout)

	-- Ears (welded to head)
	local lEar = mkPart("LeftEar",  Vector3.new(1*S, 2*S, 0.3*S), Vector3.new(OX - 1.3*S, OY + 2.55*S, OZ + 5.5*S), config.HeadColor)
	local rEar = mkPart("RightEar", Vector3.new(1*S, 2*S, 0.3*S), Vector3.new(OX + 1.3*S, OY + 2.55*S, OZ + 5.5*S), config.HeadColor)
	mkWeld(head, lEar)
	mkWeld(head, rEar)

	-- Tail (hinged at back of body, wags side-to-side)
	local tail = mkPart("Tail", Vector3.new(0.7*S, 0.7*S, 5*S), Vector3.new(OX, OY, OZ - 6.5*S), config.BodyColor)
	mkDrag(tail)

	-- Leg Y levels
	local bodyBotY = OY - 1.5 * S
	local ulCY = bodyBotY - UL_HALF
	local llCY = ulCY - UL_HALF - LL_HALF
	local pwCY = llCY - LL_HALF - 0.25 * S

	local legZF = OZ + 2.5 * S
	local legZB = OZ - 2.5 * S
	local legXL = OX - 2 * S
	local legXR = OX + 2 * S

	local function mkLegSet(pfx: string, lx: number, lz: number): (Part, Part, Part)
		local ul = mkPart(pfx.."UpperLeg", Vector3.new(1.2*S, 4*S*LL, 1.2*S), Vector3.new(lx, ulCY, lz), config.LegsColor)
		local ll = mkPart(pfx.."LowerLeg", Vector3.new(1.0*S, 3.5*S*LL, 1.0*S), Vector3.new(lx, llCY, lz), config.LegsColor)
		local pw = mkPart(pfx.."Paw",      Vector3.new(2.5*S, 0.5*S, 1.5*S),   Vector3.new(lx, pwCY, lz), config.LegsColor)
		mkDrag(ul); mkDrag(ll); mkDrag(pw)
		return ul, ll, pw
	end

	local flUL, flLL, flPW = mkLegSet("FL", legXL, legZF)
	local frUL, frLL, frPW = mkLegSet("FR", legXR, legZF)
	local blUL, blLL, blPW = mkLegSet("BL", legXL, legZB)
	local brUL, brLL, brPW = mkLegSet("BR", legXR, legZB)

	-- Neck: BallSocket connecting body front to head back
	local nbAtt = mkAtt("NeckBodyAtt", body, Vector3.new(0, 0, 4*S))
	local nhAtt = mkAtt("NeckHeadAtt", head, Vector3.new(0, 0, -1.5*S))
	mkBall("NeckSocket", nbAtt, nhAtt, body)

	-- Tail: Hinge rotates around Y (side-to-side wag)
	-- Rotate attachment 90° around Z so the hinge X-axis points along world Y
	local tbAtt = mkAttCF("TailBodyAtt", body, CFrame.new(0, 0, -4*S) * CFrame.Angles(0, 0, math.pi/2))
	local trAtt = mkAttCF("TailRootAtt", tail, CFrame.new(0, 0, 2.5*S) * CFrame.Angles(0, 0, math.pi/2))
	mkHinge("TailHinge", tbAtt, trAtt, body)

	-- Leg joints: Hip (BallSocket) + Knee (Hinge) + Ankle (Hinge)
	local function attachLeg(pfx: string, hipLocal: Vector3, ul: Part, ll: Part, pw: Part)
		local hipB = mkAtt(pfx.."HipBdy", body, hipLocal)
		local hipL = mkAtt(pfx.."HipLeg", ul, Vector3.new(0, UL_HALF, 0))
		mkBall(pfx.."Hip", hipB, hipL, body)

		local knUp = mkAtt(pfx.."KneeUp", ul, Vector3.new(0, -UL_HALF, 0))
		local knLo = mkAtt(pfx.."KneeLo", ll, Vector3.new(0, LL_HALF, 0))
		mkHinge(pfx.."Knee", knUp, knLo, ul)

		local akLg = mkAtt(pfx.."AnkLeg", ll, Vector3.new(0, -LL_HALF, 0))
		local akPw = mkAtt(pfx.."AnkPaw", pw, Vector3.new(0, 0.25*S, 0))
		mkHinge(pfx.."Ankle", akLg, akPw, ll)
	end

	attachLeg("FL", Vector3.new(-2*S, -1.5*S,  2.5*S), flUL, flLL, flPW)
	attachLeg("FR", Vector3.new( 2*S, -1.5*S,  2.5*S), frUL, frLL, frPW)
	attachLeg("BL", Vector3.new(-2*S, -1.5*S, -2.5*S), blUL, blLL, blPW)
	attachLeg("BR", Vector3.new( 2*S, -1.5*S, -2.5*S), brUL, brLL, brPW)

	-- Handles (anchored)
	local HY = OY + 18 * S

	local bodyHdl = mkPart("BodyHandle", Vector3.new(14*S, 1*S, 1*S), Vector3.new(OX, HY, OZ + 3*S), config.HandlesColor, true)
	mkDrag(bodyHdl)

	local legHdl = mkPart("LegHandle", Vector3.new(8*S, 1*S, 8*S), Vector3.new(OX, HY, OZ - 4*S), config.HandlesColor, true)
	mkDrag(legHdl)

	-- Handle rope attachments
	local bhBodyAtt = mkAtt("BH_BodyAtt", bodyHdl, Vector3.new(0, -0.5*S, -2*S))
	local bhHeadAtt = mkAtt("BH_HeadAtt", bodyHdl, Vector3.new(0, -0.5*S,  2*S))
	local bodyTopAtt = mkAtt("BodyTopRope", body,    Vector3.new(0,  1.5*S, 0))
	local headTopAtt = mkAtt("HeadTopRope", head,    Vector3.new(0,  1.75*S, 0))

	local lhFL = mkAtt("LH_FL", legHdl, Vector3.new(-3*S, -0.5*S,  3.5*S))
	local lhFR = mkAtt("LH_FR", legHdl, Vector3.new( 3*S, -0.5*S,  3.5*S))
	local lhBL = mkAtt("LH_BL", legHdl, Vector3.new(-3*S, -0.5*S, -3.5*S))
	local lhBR = mkAtt("LH_BR", legHdl, Vector3.new( 3*S, -0.5*S, -3.5*S))

	local flKR = mkAtt("FL_KneeRope", flUL, Vector3.new(0, -UL_HALF, 0))
	local frKR = mkAtt("FR_KneeRope", frUL, Vector3.new(0, -UL_HALF, 0))
	local blKR = mkAtt("BL_KneeRope", blUL, Vector3.new(0, -UL_HALF, 0))
	local brKR = mkAtt("BR_KneeRope", brUL, Vector3.new(0, -UL_HALF, 0))

	-- Ropes (length = current distance + small slack)
	local function ropeBetween(name: string, a0: Attachment, a1: Attachment, container: Instance)
		local len = (a0.WorldPosition - a1.WorldPosition).Magnitude + 0.5 * S
		mkRope(name, a0, a1, len, container)
	end

	ropeBetween("BodyRope",   bhBodyAtt, bodyTopAtt, bodyHdl)
	ropeBetween("HeadRope",   bhHeadAtt, headTopAtt, bodyHdl)
	ropeBetween("FLKneeRope", lhFL, flKR, legHdl)
	ropeBetween("FRKneeRope", lhFR, frKR, legHdl)
	ropeBetween("BLKneeRope", lhBL, blKR, legHdl)
	ropeBetween("BRKneeRope", lhBR, brKR, legHdl)

	if recording then
		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end
end

return createDogMarionette
