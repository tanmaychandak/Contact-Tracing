({
    updateStatus: function (component) {
        const recordId = component.get("v.recordId");

        const action = component.get("c.updateHealthStatus");
        action.setParams({
            personId: recordId
        });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                this.showToast("Success", "Person health status updated", "success");
            }
        });

        $A.enqueueAction(action);
    },

    showToast: function (titleValue, messageValue, typeValue) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: titleValue,
            message: messageValue,
            type: typeValue
        });
        toastEvent.fire();
    }
});
