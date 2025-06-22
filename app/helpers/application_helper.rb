module ApplicationHelper
    def receptionist?
        current_user.role == "receptionist"
    end
end
