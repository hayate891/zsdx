package zsdx.gui.edit_entities;

import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import zsdx.*;
import zsdx.entities.*;
import zsdx.gui.*;
import zsdx.map_editor_actions.*;

/**
 * A component to edit a chest.
 */
public class EditChestComponent extends EditEntityComponent {

    // specific fields of a chest
    private RadioField sizeField;
    private EnumerationChooser<TreasureContent> contentField;
    private NumberChooser amountField;
    private JCheckBox saveField;
    private NumberChooser savegameVariableField;

    /**
     * Constructor.
     * @param map the map
     * @param entity the entity to edit
     */
    public EditChestComponent(Map map, MapEntity entity) {
	super(map, entity);
    }

    /**
     * Creates the specific fields for this kind of entity.
     */
    protected void createSpecificFields() {

	// big or small chest
	sizeField = new RadioField("Small", "Big");
	addField("Chest type", sizeField);

	// treasure content
	contentField = new EnumerationChooser<TreasureContent>(TreasureContent.class);
	addField("Treasure", contentField);

	// treasure amount
	amountField = new NumberChooser(1, 1, 999);
	addField("Amount", amountField);

	// treasure saving option
	saveField = new JCheckBox("Save the chest state");
	saveField.setSelected(true);
	addField("Savegame", saveField);

	// treasure savegame variable
	savegameVariableField = new NumberChooser(0, 0, 32767);
	addField("Savegame variable", savegameVariableField);

	// enable or disable the amount field depending on the treasure content
	contentField.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent ev) {

		boolean treasurePresent = (contentField.getValue() != TreasureContent.NOTHING);
		amountField.setEnabled(treasurePresent && contentField.getValue().hasAmount());
		savegameVariableField.setEnabled(treasurePresent);
	    }
	});

	// enable or disable the savegame index field depending on the check box
	saveField.addChangeListener(new ChangeListener() {
	    public void stateChanged(ChangeEvent ev) {
		savegameVariableField.setEnabled(saveField.isSelected());
	    }
	});
    }

    /**
     * Updates the information displayed in the fields.
     */
    public void update() {
	super.update(); // update the common fields

	Chest chest = (Chest) entity;

	int savegameVariable = chest.getIntegerProperty("savegameVariable");
	sizeField.setSelectedIndex(chest.isBigChest() ? 1 : 0);
	contentField.setValue(TreasureContent.get(chest.getIntegerProperty("content")));
	amountField.setNumber(chest.getIntegerProperty("amount"));
	saveField.setSelected(savegameVariable != -1);
	savegameVariableField.setNumber(savegameVariable);
	savegameVariableField.setEnabled(savegameVariable != -1);
    }

    /**
     * Returns the specific part of the action made on the entity.
     * @return the specific part of the action made on the entity
     */
    protected ActionEditEntitySpecific getSpecificAction() {
	return new ActionEditEntitySpecific(entity,
		sizeField.getSelectedIndex(),
		contentField.getValue().getIndex(),
		amountField.getNumber(),
		saveField.isSelected() ? savegameVariableField.getNumber() : -1);
    }
}
