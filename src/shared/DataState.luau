-- Data loading waiter by zen

local DataState = {
	IsLoaded = false,
	Bindable = Instance.new("BindableEvent"),
}

function DataState:WaitUntilLoaded()
	if self.IsLoaded then
		return
	end
	self.Bindable.Event:Wait()
end

function DataState:SetLoaded()
	self.IsLoaded = true
	self.Bindable:Fire()
end

return DataState
